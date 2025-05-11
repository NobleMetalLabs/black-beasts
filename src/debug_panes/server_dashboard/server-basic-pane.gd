extends Control

func _process(delta):
	ImGui.SetNextWindowSize(self.get_size())
	ImGui.SetNextWindowPos(self.global_position)
	var window_flags = ImGui.WindowFlags_NoResize | ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoMove
	if ImGui.Begin("Server", [], window_flags):
		ImGui.Text("ImGui in")
		ImGui.SameLine()
		#ImGui.TextLinkOpenURLEx("Godot %s" % gdver, "https://www.godotengine.org")


		# ImGui.DragFloat("myfloat", myfloat)
		# ImGui.Text(str(myfloat[0]))
		# ImGui.InputText("mystr", mystr, 32)
		# ImGui.Text(mystr[0])

		# ImGui.PlotHistogram("histogram", values, values.size())
		# ImGui.PlotLines("lines", values, values.size())
		# ImGui.ListBox("choices", current_item, items, items.size())
		# ImGui.Combo("combo", current_item, items)
		# ImGui.Text("choice = %s" % items[current_item[0]])

		ImGui.SeparatorText("Multi-Select")
	ImGui.End()