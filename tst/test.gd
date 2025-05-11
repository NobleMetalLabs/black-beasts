extends Node

@onready var client : NetworkClient = self.get_parent()

var cnt : float = 0
func _process(_delta):
	if not client.connected: return

	ping()

	# cnt += delta
	# if cnt > 0.2:
	# 	cnt = 0
	# 	ping()
	# fmod(cnt, 0.2)

func ping():
	client.send_network_request("ping")