extends StaticBody

onready var anim = $AnimationPlayer
var done = false

signal activated

export(NodePath) var node_path
onready var target = get_node(node_path)

func interact():
	
	if not done:
		anim.play("Activate")
		yield(anim, "animation_finished")
		emit_signal("activated")
		target.activate()
		done = true


func prompt(vis):
	if not done:
		$InteractPrompt.visible = vis


func _on_Lever_activated():
	$InteractPrompt.visible = false
