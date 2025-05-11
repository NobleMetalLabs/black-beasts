extends Node

func _ready():
	var args := Array(OS.get_cmdline_args())
	if args.has("-client"):
		get_tree().change_scene_to_file.call_deferred("res://scn/client_dashboard.tscn")
	if args.has("-server"):
		get_tree().change_scene_to_file.call_deferred("res://scn/server_dashboard.tscn")