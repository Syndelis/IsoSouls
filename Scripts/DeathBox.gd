extends Area


func _on_DeathBox_body_entered(body):
	if Global.isPlayer(body):
		body.kill()
		
	elif body.is_in_group("Enemy") or body.is_in_group("Fireball"):
		body.queue_free()
