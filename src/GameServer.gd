class_name GameServer
extends Node

@onready var server : NetworkServer = self.get_parent()

var state : GameState :
	get: return $GameManager.state

func _ready():
	server.received_network_request.connect(on_request)

func on_request(sender : int, message : String, _data : Array, _timestamp : int) -> void:
	if message == "new_participant/request":
		print("Participant request from %d" % sender)
		setup_new_participant(sender)
		return

func setup_new_participant(for_peer : int) -> void:
	print("New player: %d" % for_peer)
	
	var partip := GameParticipant.new()
	state.game_participants_by_id[partip.id] = partip
	server.send_network_response(
		"new_participant/reply", [partip.id], for_peer
	)