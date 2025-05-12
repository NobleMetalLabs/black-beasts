extends Control

@onready var server : NetworkServer = get_tree().get_root().get_node("root")

func _ready():
	server.received_network_request.connect(on_request)
	server.sent_network_response.connect(on_response)

var message_buffer : Array[Dictionary] = []

func on_request(sender_id : int, message : String, args : Dictionary = {}, timestamp : int = 0):
	var output : Dictionary = {}
	output["was_server"] = false
	output["message"] = message
	if args.size() > 0:
		output["args"] = args
	if sender_id != -1:
		output["sender_id"] = sender_id
	if timestamp != 0:
		output["timestamp"] = timestamp
	message_buffer.append(output)
	if message_buffer.size() > 10:
		message_buffer.pop_front()
	sort_messages()

func on_response(recipient : int, message : String, args : Dictionary = {}, timestamp : int = 0):
	var output : Dictionary = {}
	output["was_server"] = true
	output["message"] = message
	if args.size() > 0:
		output["args"] = args
	if recipient != -1:
		output["recipient_id"] = recipient
	if timestamp != 0:
		output["timestamp"] = timestamp
	message_buffer.append(output)
	if message_buffer.size() > 10:
		message_buffer.pop_front()
	sort_messages()

func sort_messages():
	message_buffer.sort_custom(
		func (msg_a : Dictionary, msg_b : Dictionary) -> int:
			return msg_a["timestamp"] < msg_b["timestamp"]
	)

func _process(_delta):
	ImGui.SetNextWindowSize(self.get_size())
	ImGui.SetNextWindowPos(self.global_position)
	var window_flags = ImGui.WindowFlags_NoResize | ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoMove
	if ImGui.Begin("Events", [], window_flags):
		ImGui.SetNextItemOpen(true)
		if ImGui.TreeNode("Network messages"):
			for i : int in range(message_buffer.size()):
				var message_dict : Dictionary = message_buffer[i]
				var message_rows : Array = []
				if message_dict.get("was_server"):
					message_rows.append("Server response: %s" % message_dict["message"])
				else:
					message_rows.append("Client message: %s" % message_dict["message"])
				if message_dict.has("args"):
					message_rows.append("Args: %s" % str(message_dict.get("args")))
				if message_dict.has("sender_id"):
					message_rows.append("Sender ID: %s" % message_dict.get("sender_id"))
				if message_dict.has("recipient_id"):
					message_rows.append("Recipient ID: %s" % message_dict.get("recipient_id"))
				if message_dict.has("timestamp"):
					message_rows.append("Timestamp: %s" % message_dict.get("timestamp"))
				ImGui.PushID(str(i))
				ImGui.SetNextItemOpen(true)
				if ImGui.TreeNode(message_rows[0]):
					for j in range(1, message_rows.size()):
						ImGui.PushID(str(j))
						ImGui.Text(message_rows[j])
						ImGui.PopID()
					ImGui.Separator()
					ImGui.TreePop()
				ImGui.PopID()
			ImGui.TreePop()
	ImGui.End()