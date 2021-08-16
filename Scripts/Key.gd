extends Area
export(int, FLAGS, "Alpha", "Beta", "Gamma") var which = 0

func _on_Key_body_entered(body):
	if Global.isPlayer(body):
		Global.Player.give(which)
		queue_free()
