extends Sprite

onready var parent = get_parent()
onready var prog = parent.texture_progress.get_width()

var size = texture.get_width()

func _ready():
	_on_TextureProgress_value_changed(parent.value)

func _on_TextureProgress_value_changed(value):
	
	var v = prog / parent.max_value
	position.x = clamp(v * value, v * 2, v * 94) - 8 * value / parent.max_value


func _on_Orange_value_changed(value):
	_on_TextureProgress_value_changed(value)
