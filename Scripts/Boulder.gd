extends RigidBody



func _on_BoulderTrigger_body_entered(body):
	if Global.isPlayer(body):
		add_force(Vector3(0, 0, 500 * weight), Vector3.ZERO)


func _on_Hitbox_body_entered(body):
	if Global.isPlayer(body):
		body.kill()
		body.knock(transform.origin, 5)


func _on_BoulderKillBox_body_entered(body):
	if body == self:
		queue_free()
