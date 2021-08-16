extends Spatial

export var Reach = 6
export var Randomness = 0.3
onready var light = $Club/Tip/OmniLight

var newV = 0

func _process(delta):
	light.omni_range = lerp(light.omni_range, newV, 0.2)
	var c = randf() * 0.2
	light.shadow_color = Color(c, c, c)


func _on_Timer_timeout():	
	newV = rand_range(Reach * (1 - Randomness), Reach * (1 + Randomness))
