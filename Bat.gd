extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#pass # Replace with function body.
	$AnimationPlayer.get_animation("Bat_Flying").set_loop(true)
	$AnimationPlayer.play("Bat_Flying")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
