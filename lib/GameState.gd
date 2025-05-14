class_name GameState
extends Serializeable

var game_id : int = 0
var game_participants_by_id : Dictionary = {} #[int, GameParticipant]

var companies : Array[Company] = []
