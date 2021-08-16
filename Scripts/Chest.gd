extends StaticBody

enum Type {Gear, Health, Sword}

export(Type) var type
export(String, FILE, "*.obj") var gear
export(String, "Head", "Neck") var where

var node_gear
onready var anim = $AnimationPlayer

enum State {Empty, Open, Closed}
var state = State.Closed

func _ready():
	
	match type:
		
		Type.Gear:
			node_gear = MeshInstance.new()
			node_gear.mesh = load(gear)
			$Item.add_child(node_gear)
		
		Type.Health:
			$Item/OmniLight.light_color = Color.red
			$Item/Heart.visible = true
			
		Type.Sword:
			$Item/OmniLight.light_color = Color.orange
			$Item/Sword.visible = true

func interact():
	match state:
		State.Empty:
			state = State.Closed
			anim.play("Close")
			yield(anim, "animation_finished")
			anim.play("Closed")
			
			
		State.Open:
			state = State.Empty
			
			match type:
				
				Type.Gear:
					Global.Player.equip(node_gear, where)
				
				Type.Health:
					Global.Player.heal(4)
					
				Type.Sword:
					Global.Player.giveSword()
			
			$Item.visible = false
			
			
		State.Closed:
			state = State.Open
			anim.play("Open")
			yield(anim, "animation_finished")
			anim.play("Opened")


func prompt(vis):
	$InteractPrompt.visible = vis
