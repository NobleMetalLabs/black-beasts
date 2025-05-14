extends Control

var state : GameState 
func _ready():
	print(1)
	(
		func a():
			state = get_tree().get_root().get_node("root/GameServer").state
	).call_deferred()

func _process(_delta):
	ImGui.SetNextWindowSize(self.get_size())
	ImGui.SetNextWindowPos(self.global_position)
	var window_flags = ImGui.WindowFlags_NoResize | ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoMove
	ImGui.Begin("Game State", [], window_flags)
	ImGui.Text("Test")
	ImGui.Text(str(state))
	ImGui.End()
