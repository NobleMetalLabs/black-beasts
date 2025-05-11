extends Node

var cnt : float = 0
func _process(delta):
	if MultiplayerManager.is_instance_server():
		get_tree().change_scene_to_file("res://scn/server_dashboard.tscn")

	ping()

	# cnt += delta
	# if cnt > 0.2:
	# 	cnt = 0
	# 	ping()
	# fmod(cnt, 0.2)

func ping():
	MultiplayerManager.send_network_message("ping")
	MultiplayerManager.network_update.emit()