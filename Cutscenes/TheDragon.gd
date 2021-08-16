extends Node



func _on_Trigger_body_entered(body):
	#if body.name == "Player":
	if Global.isPlayer(body):
#		body.state = body.State.Cutscene
		body.startCutscene()
		$AnimationPlayer.play("DragonAttack")
