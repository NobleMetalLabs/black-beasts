class_name GameParticipant
extends Resource

var id : int = int(Time.get_unix_time_from_system()) #FIXME: this is horrible lol
var info_permissions : Array[InfoPermission] = []
