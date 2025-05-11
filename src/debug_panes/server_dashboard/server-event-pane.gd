extends Control

@onready var server : NetworkServer = get_tree().get_root().get_node("root")

func _ready():
	server.received_network_request.connect(on_request)

var message_buffer : Array[Array] = []

func on_request(sender_id : int, message : String, args : Array = [], timestamp : int = 0):
	var output : Array[String] = []
	output.append("Network message: %s" % message)
	if args.size() > 0:
		output.append("Args: %s" % str(args))
	if sender_id != -1:
		output.append("Sender ID: %s" % sender_id)
	if timestamp != 0:
		output.append("Timestamp: %s" % timestamp)
	message_buffer.append(output)
	if message_buffer.size() > 10:
		message_buffer.pop_front()

func _process(_delta):
	ImGui.SetNextWindowSize(self.get_size())
	ImGui.SetNextWindowPos(self.global_position)
	var window_flags = ImGui.WindowFlags_NoResize | ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoMove
	if ImGui.Begin("Events", [], window_flags):
		ImGui.SetNextItemOpen(true)
		if ImGui.TreeNode("Network messages"):
			for i : int in range(message_buffer.size()):
				var message : Array = message_buffer[i]
				ImGui.PushID(str(i))
				ImGui.SetNextItemOpen(true)
				if ImGui.TreeNode(message[0]):
					for j in range(1, message.size()):
						ImGui.PushID(str(j))
						ImGui.Text(message[j])
						ImGui.PopID()
					ImGui.Separator()
					ImGui.TreePop()
				ImGui.PopID()
			ImGui.TreePop()
	ImGui.End()