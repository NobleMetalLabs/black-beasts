class_name GameManger
extends Node

var state : GameState

func _ready():
	_load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		_save_game()

func _save_game(dir : String = "res://tst/current_game/") -> void:
	var fa = FileAccess.open("%s/game_state.dat" % dir, FileAccess.WRITE)
	fa.store_var(state.serialize())
	Logger.log("SERVER, DISK", "Game state saved.")
	fa.close()

func _load_game(dir : String = "res://tst/current_game/") -> void:
	var fa := FileAccess.open("%s/game_state.dat" % dir, FileAccess.READ)
	if FileAccess.get_open_error() == ERR_FILE_NOT_FOUND: 
		Logger.log("SERVER, DISK", "No saved game found, creating a new one.")
		state = GameState.new()
		return
	var state_dict : Dictionary = fa.get_var()
	state = Serializeable.deserialize(state_dict)
	Logger.log("SERVER, DISK", "Loaded game state.")
	fa.close()