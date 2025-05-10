extends Node

func _process(delta):
	if MultiplayerManager.is_instance_server():
		get_tree().change_scene_to_file("res://scn/server.tscn")

	MultiplayerManager.send_network_message("ping")