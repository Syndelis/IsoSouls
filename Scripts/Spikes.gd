extends Area

onready var anim = $AnimationPlayer

func activate():
	anim.play("Fall")


func _on_Spikes_body_entered(body):
	#if body.name == "Player":
	if Global.isPlayer(body):
		# Kill Player
		body.kill()
		body.visible = false
