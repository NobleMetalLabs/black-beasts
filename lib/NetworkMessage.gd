class_name NetworkMessage
extends Serializeable

var sender_peer_id : int
var message : String
var args : Array

static func setup(_sender_peer_id : int, _message : String, _args : Array) -> NetworkMessage:
	var nm := NetworkMessage.new()
	nm.sender_peer_id = _sender_peer_id
	nm.message = _message
	nm.args = _args
	return nm

func _to_string() -> String:
	return "NetworkMessage(%s, %s, %s)" % [sender_peer_id, message, args]
