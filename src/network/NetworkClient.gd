class_name NetworkClient
extends Node

signal network_connected()
signal network_disconnected()

var connected : bool = false
var multiplayer_peer := ENetMultiplayerPeer.new()

var ADDRESS : String
const PORT = 31570

func _ready() -> void:
	multiplayer.peer_connected.connect(
		func sv_conn(peer_id : int): 
			if peer_id == 1: 
				connected = true
				network_connected.emit()
	)
	multiplayer.peer_disconnected.connect(
		func sv_disconn(peer_id : int): 
			if peer_id == 1: 
				connected = false
				network_disconnected.emit()
	)

	var auto_connect : Callable = \
		func auto_connect() -> void:
			var args := Array(OS.get_cmdline_args())
			if args.has("--client"):
				join_lobby()
	
	auto_connect.call_deferred()

func get_peer_id() -> int:
	return multiplayer.get_unique_id()

func join_lobby(address : String = "127.0.0.1") -> void:
	multiplayer_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	Logger.log("CLIENT, SERVER", "Joined server with clientid %s" % [multiplayer.get_unique_id()])

func exit_lobby() -> void:
	multiplayer_peer.disconnect_peer(get_peer_id())
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer.multiplayer_peer = null
	Logger.log("CLIENT, SERVER", "Left server")

func send_network_request(message : String, args : Dictionary = {}) -> void:
	var sender_id : int = get_peer_id()
	var timestamp : int = int(Time.get_unix_time_from_system() * 1000)
	var msg_obj := NetworkMessage.setup(sender_id, message, args, timestamp)
	var msg_dict : Dictionary = msg_obj.serialize()
	Logger.log("CLIENT, NETWORK, %s" % sender_id, 
		"\"%s\" w/ %s @ %s" % [
			message, args, "::%s" % str(timestamp).right(5)
		]
	)
	if not connected:
		Logger.error("Can't send network request: Not connected to server")
		return

	rpc_id(1, "receive_network_request", var_to_bytes(msg_dict))

@rpc("authority", "reliable")
func receive_network_response(bytes : PackedByteArray) -> void:
	var msg_dict : Dictionary = bytes_to_var(bytes)
	#print("\n%s : Handling message \n%s\n" % [get_peer_id(), JSON.stringify(msg_dict, "\t")])
	var message : NetworkMessage = Serializeable.deserialize(msg_dict)
	#print("%s : Handling message %s" % [get_peer_id(), message])
	received_network_response.emit(message.message, message.args, message.timestamp)

@rpc("any_peer", "reliable")
func receive_network_request() -> void: pass

signal received_network_response(message : String, args : Dictionary, timestamp : int)
