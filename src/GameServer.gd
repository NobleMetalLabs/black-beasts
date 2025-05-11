class_name GameServer
extends Node

var state : GameState :
	get: return $GameManager.state

func _ready():
	MultiplayerManager.received_network_message.connect(on_network_message)

func on_network_message(sender : int, message : String, _data : Array, _timestamp : int) -> void:
	if message == "new_participant/request":
		print("Participant request from %d" % sender)
		setup_new_participant(sender)
		return

func setup_new_participant(for_peer : int) -> void:
	print("New player: %d" % for_peer)
	
	var partip := GameParticipant.new()
	state.game_participants_by_id[partip.id] = partip
	MultiplayerManager.send_network_message(
		"new_participant/reply", [partip.id], for_peer, true
	)