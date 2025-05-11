#class_name GameManger
extends Node

var game_participants_by_id : Dictionary = {} #[int, GameParticipant]

func _save_game(dir : String = "res://tst/current_game/") -> void:
	# Save game logic here
	print("Game saved")

func _load_game(dir : String = "res://tst/current_game/") -> void:
	# Load game logic here
	print("Game loaded")