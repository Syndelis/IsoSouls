extends Spatial

func _ready():
	Global.Player = $Player
	Global.HUD = $CanvasLayer/HUD


func _on_End_body_entered(body):
	if Global.isPlayer(body):
		get_tree().change_scene("res://Scenes/End.tscn")
