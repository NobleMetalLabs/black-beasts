#class_name MultiplayerManager
extends Node

signal network_update()

# TODO: Rewrite this entire class
# 1. ENet (maybe all MultiplayerPeer subclasses) are aware of every connected peer indivudally, new archi should only be client-server
# 2. Loopback shouldnt exist as client updates are always dictated by the server
# 3. Honestly server and client maybe should be separate classes

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
			if args.has("-server"):
				host_lobby()
			elif args.has("-client"):
				join_lobby()
	
	auto_connect.call_deferred()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if upnp.get_device_count() > 0:
			upnp.delete_port_mapping(PORT, "UDP")
			upnp.delete_port_mapping(PORT, "TCP")

func get_peer_id() -> int:
	return multiplayer.get_unique_id()

func is_instance_server() -> bool:
	if multiplayer.multiplayer_peer == null: return false
	return multiplayer.get_unique_id() == 1

func host_lobby() -> void:
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Server started on port %s with clientid %s" % [PORT, multiplayer.get_unique_id()])
	network_update.emit()

func join_lobby(address : String = "127.0.0.1") -> void:
	multiplayer_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Joined server with clientid %s" % [multiplayer.get_unique_id()])

func exit_lobby() -> void:
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer.multiplayer_peer = null
	print("Left server")
	network_update.emit()

func on_player_connected(peer_id : int) -> void:
	print("Player %s connected" % peer_id)
	peers.append(peer_id)
	network_update.emit()

func on_player_disconnected(peer_id : int) -> void:
	if peer_id == 1:
		print("Host disconnected.")
		return
	peers.erase(peer_id)
	network_update.emit()

func send_network_message(message : String, args : Array = [], recipient_id : int = -1, remote_only : bool = true) -> void:
	var sender_id : int = get_peer_id()
	var timestamp : int = int(Time.get_unix_time_from_system() * 1000)
	var msg_obj := NetworkMessage.setup(sender_id, message, args, timestamp)
	var msg_dict : Dictionary = msg_obj.serialize()
	#print("%s : Sending message %s" % [sender_id, msg_obj])
	#print("%s : Sending message %s" % [get_peer_id(), msg_dict])
	var recipients : Array[int] = peers
	if recipient_id != -1:
		recipients = [recipient_id]
	for peer_id in recipients:
		var peer_obj : ENetPacketPeer = multiplayer_peer.get_peer(peer_id)
		if peer_obj == null: continue
		var peer_status : ENetPacketPeer.PeerState = peer_obj.get_state()
		if peer_status != ENetPacketPeer.STATE_CONNECTED: 
			print("%s:%s" % [peer_id, peer_status])
			continue
		rpc_id(peer_id, "receive_network_message", var_to_bytes(msg_dict))
	if remote_only: return
	received_network_message.emit(sender_id, message, args)

@rpc("any_peer", "reliable")
func receive_network_message(bytes : PackedByteArray) -> void:
	var msg_dict : Dictionary = bytes_to_var(bytes)
	#print("\n%s : Handling message \n%s\n" % [get_peer_id(), JSON.stringify(msg_dict, "\t")])
	var message : NetworkMessage = Serializeable.deserialize(msg_dict)
	#print("%s : Handling message %s" % [get_peer_id(), message])
	received_network_message.emit(message.sender_peer_id, message.message, message.args, message.timestamp)

signal received_network_message(sender : int, message : String, args : Array, timestamp : int)
