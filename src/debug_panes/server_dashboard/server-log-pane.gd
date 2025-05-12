extends Control

func _ready():
	Logger.logged.connect(logs.append)

var logs : Array[String] = []

func _process(_delta):
	ImGui.SetNextWindowSize(self.get_size())
	ImGui.SetNextWindowPos(self.global_position)
	var window_flags = ImGui.WindowFlags_NoResize | ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoMove
	if ImGui.Begin("Log", [], window_flags):
		for i in range(logs.size()):
			ImGui.PushID(str(i))
			var segs : Array[String] = []
			segs.assign(logs[i].split("[/color]"))
			var msg : String = segs.pop_back()
			for seg : String in segs:
				seg = seg.trim_prefix("[color=")
				var halv : PackedStringArray = seg.split("]", false, 1)
				var color : String = halv[0]
				var tag : String = halv[1]
				ImGui.TextColored(color, tag)
				ImGui.SameLineEx(0, 0)
			ImGui.Text(msg)
			ImGui.PopID()
	ImGui.End()