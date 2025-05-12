class_name ClientSaves
extends Node

var player_id : int
var participant_id_by_game_id : Dictionary = {} #[int, int]

@onready var client : NetworkClient = self.get_parent()

func _ready():
	client.received_network_response.connect(handle_network_response)

	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.trim_prefix("--")] = ""

	player_id = arguments.get("player_id", 0).to_int()
	load_participant_ids()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		save_participant_ids()

func save_participant_ids(dir : String = "res://tst/current_game/") -> void:
	var fa = FileAccess.open("%s/%s.dat" % [dir, player_id], FileAccess.WRITE)
	fa.store_var(Serializeable.serialize_variant(participant_id_by_game_id))
	Logger.log("CLIENT, DISK", "Participant ids saved.")
	fa.close()

func load_participant_ids(dir : String = "res://tst/current_game/") -> void:
	var fa := FileAccess.open("%s/%s.dat" % [dir, player_id], FileAccess.READ)
	if FileAccess.get_open_error() == ERR_FILE_NOT_FOUND: 
		Logger.log("CLIENT, DISK", "No ids found.")
		participant_id_by_game_id = {}
		return
	var state_dict : Dictionary = fa.get_var()
	participant_id_by_game_id = Serializeable.deserialize(state_dict)
	Logger.log("CLIENT, DISK", "Loaded participant ids: %s" % [participant_id_by_game_id])
	fa.close()

func handle_network_response(message : String, args : Dictionary, _timestamp : int) -> void:
	match message:
		"participant/id_request":
			var game_id : int = args["game_id"]
			Logger.log("CLIENT, SERVER, REQUEST", "Server requests participant id for game %s" % game_id)
			var participant_id : int = -1
			if participant_id_by_game_id.has(game_id):
				participant_id = participant_id_by_game_id[game_id]
				Logger.log("CLIENT, PROCESS", "Saved id %s retrieved" % participant_id)
			if participant_id == -1:
				Logger.log("CLIENT, RESPONSE", "None saved, requesting new id")
			else:
				Logger.log("CLIENT, RESPONSE", "Providing...")
			client.send_network_request(
				"participant/id_reply", {
					"game_id" : game_id,
					"participant_id" : participant_id 
				}
			)
		"participant/new_id_reply":
			var game_id : int = args["game_id"]
			var participant_id : int = args["participant_id"]
			Logger.log("CLIENT, SERVER, RESPONSE", "Server provided new participant id %s" % participant_id)
			participant_id_by_game_id[game_id] = participant_id
			Logger.log("CLIENT, PROCESS", "Id recorded")

	