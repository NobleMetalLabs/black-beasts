class_name GameParticipant
extends Serializeable

var id : int = int(Time.get_unix_time_from_system()) #FIXME: this is horrible lol
var info_permissions : Array[InfoPermission] = []
#var action_permissions : Array[ActionPermission] = []
