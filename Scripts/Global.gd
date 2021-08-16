extends Node

var Player = null# = get_tree().root.get_node("/root/Test/Player")
var HUD = null# = get_tree().root.get_node("/root/Test/CanvasLayer/HUD")


func isPlayer(body):
	return body == Player


func resetGame():
	HUD.resetView()
