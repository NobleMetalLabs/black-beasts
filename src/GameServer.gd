class_name GameServer
extends Node

@onready var server : NetworkServer = self.get_parent()

var peer_to_participant_id : Dictionary = {} #[int, int]

var state : GameState :
	get: return $GameManager.state

func _ready():
	server.peer_connected.connect(on_connected)
	server.received_network_request.connect(on_request)

func on_connected(sender : int) -> void:
	print("Peer %d connected" % sender)
	server.send_network_response(sender,
		"participant/id_request", {
			"game_id" : state.game_id
		}
	)

func on_request(sender : int, message : String, args : Dictionary, _timestamp : int) -> void:
	if message == "participant/id_reply":
		var game_id : int = args["game_id"]
		var participant_id : int = args["participant_id"]
		if game_id != state.game_id: return
		if participant_id == -1:
			print("Peer %s requests new participant assignment" % sender)
			var new_id : int = setup_new_participant(sender)
			server.send_network_response(sender,
				"participant/new_id_reply", {
					"game_id" : state.game_id,
					"participant_id" : new_id
				}
			)
			return
		else:
			print("Peer %s assigned to participant %s" % [sender, participant_id])
			peer_to_participant_id[sender] = participant_id
			return

func setup_new_participant(for_peer : int) -> int:
	var partip := GameParticipant.new()
	print("NEW PARTICIPANT %s" % partip)
	state.game_participants_by_id[partip.id] = partip
	peer_to_participant_id[for_peer] = partip.id
	print(state.game_participants_by_id)
	return partip.id