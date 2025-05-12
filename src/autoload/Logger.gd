#class_name Logger
extends Node

var tags : Array[String] = [
	"disk",
	"network",
	"server",
	"client",
	"request",
	"response",
	"data",
	"sim",
	"process",
	"info",
	"ui",
]

var tag_colors : Dictionary = {
	"disk" : "VIOLET",
	"network" : "ORANGE_RED",
	"server" : "FIREBRICK",
	"client" : "CORNFLOWER_BLUE",
	"request" : "WEB_MAROON",
	"response" : "MIDNIGHT_BLUE",
	"data" : "WEB_PURPLE",
	"sim" : "MEDIUM_ORCHID",
	"process" : "DARK_ORANGE",
	"ui" : "LIME_GREEN",
	"info" : "GRAY",
}

@export var tag_visibility : Dictionary = {
	"disk" : true,
	"network" : false,
	"server" : true,
	"client" : true,
	"request" : true,
	"response" : true,
	"data" : true,
	"sim" : true,
	"process" : true,
	"ui" : true,
	"info" : true,
}

signal logged(message : String)

func log(message_tags : String, message : String) -> void:
	var tags_arr : Array[String] = []
	tags_arr.assign(message_tags.split(","))
	tags_arr.assign(tags_arr.map(func trim(tag : String) -> String: return tag.strip_edges()))
	for tag : String in tags_arr:
		if not tag_visibility.get(tag.to_lower(), true): 
			return

	var complete_message : String = "%s %s" % [_build_tagchain(tags_arr), message]
	print_rich(complete_message)
	logged.emit(complete_message)

func error(message : String) -> void:
	push_error("%s" % message)

func _build_tagchain(chain_tags : Array[String]) -> String:
	var out : Array[String] = []
	for tag : String in chain_tags:
		var tag_key : String = tag.to_lower()
		out.append("[color=%s][%s][/color]" % [tag_colors.get(tag_key, "white"), tag_key.to_upper()])
	return "".join(out)
	