extends RigidBody


func _on_Hitbox_body_entered(body):
	if Global.isPlayer(body):
		body.hit(transform.origin)
		queue_free()
