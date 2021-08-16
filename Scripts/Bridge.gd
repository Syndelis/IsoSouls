extends StaticBody

export(NodePath) var trap_path
onready var trap_lever = get_node(trap_path)

func activate():
	trap_lever.queue_free()
	$AnimationPlayer.play("Fall")
	
