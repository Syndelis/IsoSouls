extends Node

var started = false
signal fightStart

func _on_BossFightStarter_body_entered(body):
	if not started and Global.isPlayer(body):
		started = true
		body.startCutscene()
		$AnimationPlayer.play("Begin")
		emit_signal("fightStart")
		


func _on_Area_body_entered(body):
	if Global.isPlayer(body):
		body.hit($SpikesWall.transform.origin)


func end():
	$AnimationPlayer.play("End")
