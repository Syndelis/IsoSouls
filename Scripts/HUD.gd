extends Control

onready var texProg = $VBoxContainer/HBoxContainer/Node2D/TextureProgress
onready var bossHealth = $VBoxContainer/VBoxContainer/BossContainer/Node2D/TextureProgress/OrangeBoss

signal boss_health_changed(val)

func _on_Player_health_changed(health):
	
	if health <= 0 and texProg.value > 0:
		$AnimationPlayer.play("Death")
	
	texProg.value = health
	
	if $Timer.is_stopped():
		$Timer.start()


func _on_Player_cutscene(started):
	if started:
		$AnimationPlayer.play("Cutscene")
		
	else: $AnimationPlayer.play_backwards("Cutscene")


func resetView():
	$AnimationPlayer.play("Idle")
	yield($AnimationPlayer, "animation_finished")
	get_tree().reload_current_scene()


func _on_MotherSlime_fightStart():
	bossHealth.startBoss()
	print("startBoss")


func _on_MotherSlime_health_changed(val):
	emit_signal("boss_health_changed", val)
