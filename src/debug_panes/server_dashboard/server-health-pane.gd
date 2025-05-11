extends Control

const NUM_DELAY_SAMPLES : int = 25
var message_delays_array_per_peer : Dictionary = {}
var message_delays_array_index_per_peer : Dictionary = {}
var message_delays_average_per_peer : Dictionary = {}

func _ready():
	MultiplayerManager.received_network_message.connect(on_network_message)

func on_network_message(sender_id : int, _message : String, _args : Array = [], timestamp : int = 0):
	if not message_delays_array_per_peer.has(sender_id):
		var st : Array = []
		st.resize(25)
		for i in range(25):
			st[i] = "xxxms"
		message_delays_array_per_peer[sender_id] = st

	var delays_array_index : int = message_delays_array_index_per_peer.get_or_add(sender_id, 0)
	var curr_delay : int = (int(Time.get_unix_time_from_system() * 1000)) - timestamp
	message_delays_array_per_peer[sender_id][delays_array_index] = "%dms" % curr_delay
	
	message_delays_array_index_per_peer[sender_id] += 1
	message_delays_array_index_per_peer[sender_id] %= NUM_DELAY_SAMPLES

	reaverage_delays(sender_id)

func reaverage_delays(peer : int):
	if not message_delays_array_per_peer.has(peer): return
	var delays : Array = message_delays_array_per_peer[peer]
	var sum : float = 0
	var samples : int = 0
	for i in range(NUM_DELAY_SAMPLES):
		var value : String = delays[i]
		if value == "xxxms": continue
		sum += int(delays[i].replace("ms", ""))
		samples += 1
	message_delays_average_per_peer[peer] = sum / samples

func _process(delta):
	ImGui.SetNextWindowSize(self.get_size())
	ImGui.SetNextWindowPos(self.global_position)
	var window_flags = ImGui.WindowFlags_NoResize | ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoMove
	if ImGui.Begin("Health", [], window_flags):
		@warning_ignore("integer_division")
		var upt_sec : int = Time.get_ticks_msec() / 1000
		@warning_ignore("integer_division")
		var upt_min : int = upt_sec / 60
		upt_sec = upt_sec % 60
		var upt_hour : int = upt_min % 60
		upt_min = upt_min % 60
		var upt_day : int = upt_hour % 24
		@warning_ignore("integer_division")
		upt_hour = upt_hour / 24
		ImGui.Text("Server up-time: %d::%02d:%02d:%02d" % [
			upt_day, upt_hour, upt_min, upt_sec]
		)
		ImGui.Separator()
		ImGui.Text("Memory: %.1f MB / peak %.1f MB" % [
			OS.get_static_memory_usage() / 1000000.0,
			OS.get_static_memory_peak_usage() / 1000000.0])
		ImGui.Separator()
		ImGui.SetNextItemOpen(true)
		if ImGui.TreeNode("Client times"):
			for peer : int in MultiplayerManager.peers:
				if not message_delays_array_per_peer.has(peer): continue
				var node : bool = ImGui.TreeNode(str(peer))	
				ImGui.SameLine()
				ImGui.Text("avg: %.1fms" % message_delays_average_per_peer[peer])
				if node:
					if ImGui.BeginTable("times-%s" % peer, 5):
						for i : int in range(5):
							ImGui.TableNextRow()
							for j : int in range(5):
								ImGui.TableSetColumnIndex(j)
								var idx : int = i * 5 + j
								var delay : String = message_delays_array_per_peer[peer][idx]
								ImGui.Text(delay)
						ImGui.EndTable()
					ImGui.TreePop()
			ImGui.TreePop()
	ImGui.End()