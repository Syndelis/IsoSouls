extends StaticBody

onready var anim = $AnimationPlayer

func activate():
	anim.play("Collapse")
	yield(anim, "animation_finished")
	get_parent().queue_free()
