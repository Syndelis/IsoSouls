extends StaticBody

func _on_Area_body_entered(body):
	if Global.isPlayer(body):
		$AnimationPlayer.play("Collapse")
		yield($AnimationPlayer, "animation_finished")
		queue_free()
