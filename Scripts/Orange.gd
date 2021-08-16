extends TextureProgress

onready var p = get_parent()
onready var timer = $"../../../../../Timer"
var sub = 1

func _on_Timer_timeout():
	
	if value < p.value:
		value = p.value
	
	value -= sub
	sub *= 1.2
	
	if value - p.value > 0.25:
		timer.wait_time = 0.05
		timer.start()
		
	else:
		timer.wait_time = 0.6
		sub = 1
