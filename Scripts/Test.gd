extends Spatial

func _ready():
	var u = Vector2(2, 3)
	var v = Vector2(3, 2)
	
	print(u > v, v > u)
