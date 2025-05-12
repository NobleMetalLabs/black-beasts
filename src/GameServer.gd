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
	Logger.log("SERVER, CLIENT", "Client %d connected" % sender)
	Logger.log("SERVER, REQUEST", "Requesting saved participant id from client %s" % sender)
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
			Logger.log("SERVER, CLIENT, REQUEST", "Client %s requests new participant assignment" % sender)
			var new_id : int = setup_new_participant(sender)
			Logger.log("SERVER, RESPONSE", "Providing...")
			server.send_network_response(sender,
				"participant/new_id_reply", {
					"game_id" : state.game_id,
					"participant_id" : new_id
				}
			)
			return
		else:
			Logger.log("SERVER, CLIENT, RESPONSE", "Client %s provided participant_id %s" % [sender, participant_id])
			peer_to_participant_id[sender] = participant_id
			Logger.log("SERVER, PROCESS", "Assignment made")
			return

func setup_new_participant(for_peer : int) -> int:
	var partip := GameParticipant.new()
	state.game_participants_by_id[partip.id] = partip
	peer_to_participant_id[for_peer] = partip.id
	return partip.id