class_name NetworkServer
extends Node

signal peer_connected(peer_id : int)
signal peer_disconnected(peer_id : int)

var multiplayer_peer := ENetMultiplayerPeer.new()
var player_name : String = "P%s" % OS.get_process_id()

var peers : Array[int] = []

var ADDRESS : String
const PORT = 31570

var upnp : UPNP = UPNP.new()
func _ready() -> void:
	multiplayer.peer_connected.connect(on_player_connected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)

	var auto_connect : Callable = \
		func auto_connect() -> void:
			var args := Array(OS.get_cmdline_args())
			if args.has("--server"):
				host_lobby()
	
	auto_connect.call_deferred()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if upnp.get_device_count() > 0:
			upnp.delete_port_mapping(PORT, "UDP")
			upnp.delete_port_mapping(PORT, "TCP")

const PEER_ID : int = 1

func host_lobby() -> void:
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	Logger.log("SERVER, INFO", "Server started on port %s" % PORT)

func on_player_connected(peer_id : int) -> void:
	Logger.log("SERVER", "Peer %s connected" % peer_id)
	peers.append(peer_id)
	peer_connected.emit(peer_id)

func on_player_disconnected(peer_id : int) -> void:
	Logger.log("SERVER", "Peer %s disconnected" % peer_id)
	peers.erase(peer_id)
	peer_disconnected.emit(peer_id)

func send_network_response(recipient_id : int, message : String, args : Dictionary = {}) -> void:
	var timestamp : int = int(Time.get_unix_time_from_system() * 1000)
	var msg_obj := NetworkMessage.setup(PEER_ID, message, args, timestamp)
	var msg_dict : Dictionary = msg_obj.serialize()
	Logger.log("SERVER, NETWORK, CLIENT, %s" % recipient_id, 
		"\"%s\" w/ %s @ %s" % [
			message, args, "::%s" % str(timestamp).right(5)
		]
	)
	var recipients : Array[int] = peers
	if recipient_id != -1:
		recipients = [recipient_id]
	for peer_id in recipients:
		var peer_obj : ENetPacketPeer = multiplayer_peer.get_peer(peer_id)
		if peer_obj == null: continue
		var peer_status : ENetPacketPeer.PeerState = peer_obj.get_state()
		if peer_status != ENetPacketPeer.STATE_CONNECTED: continue
		rpc_id(peer_id, "receive_network_response", var_to_bytes(msg_dict))
	sent_network_response.emit(recipient_id, message, args, timestamp)

@rpc("any_peer", "reliable")
func receive_network_request(bytes : PackedByteArray) -> void:
	var msg_dict : Dictionary = bytes_to_var(bytes)
	#print("\n%s : Handling message \n%s\n" % [get_peer_id(), JSON.stringify(msg_dict, "\t")])
	var message : NetworkMessage = Serializeable.deserialize(msg_dict)
	#print("%s : Handling message %s" % [get_peer_id(), message])
	received_network_request.emit(message.sender_peer_id, message.message, message.args, message.timestamp)

@rpc("authority", "reliable")
func receive_network_response() -> void: pass

signal received_network_request(sender : int, message : String, args : Dictionary, timestamp : int)
signal sent_network_response(recipient : int, message : String, args : Dictionary, timestamp : int)