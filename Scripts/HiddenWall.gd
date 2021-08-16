extends StaticBody

export(NodePath) var propagate_path
onready var anim = $AnimationPlayer

func interact():
	anim.play("Disappear")
	
	yield(anim, "animation_finished")
	
	var propagate_node = get_node(propagate_path)
	
	if propagate_node != null:
		propagate_node.get_node("floor/AnimationPlayer").play("Disappear")
		
	queue_free()


func prompt(vis):
	pass
