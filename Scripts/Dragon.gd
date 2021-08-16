extends KinematicBody

export(NodePath) var reference_path
onready var reference = get_node(reference_path)

onready var fireball = preload("res://Prefabs/RealFireBall.tscn")

enum State {
	FireLeft,
	FireRight,
	HeadBanging,
	Recover,
	Sleeping
}

const SPEED = 30

var state = State.Sleeping

var motion = Vector3.ZERO
var target = Vector3.ZERO

const maxhealth = 3.0
var health = maxhealth

signal health_changed(val)

const maxshots = 6
var shots = 0

var headbangready = false

onready var parent = get_parent()

func _physics_process(delta):
	
	if state != State.Sleeping:
		
		if target != Vector3.ZERO:
			var _delta = target - transform.origin
			
			if _delta.length() > 5:
				$DragonArmature.rotation.y = Vector2(_delta.x, _delta.z).angle() + PI/2
				motion = SPEED * _delta.normalized()
				
				move_and_slide(motion, Vector3.UP)
			
			else:
				$DragonArmature.rotation.y += PI
				motion = Vector3.ZERO
				target = Vector3.ZERO
				
				print("starting timer")
				
				if state == State.HeadBanging:
					$Timers/HeadBang.start()
					
				else: $Timers/Fire.start()
	
		else:
			match state:
				
				State.FireLeft:  fireState()
				State.FireRight: fireState()
					
				State.HeadBanging:
					
					$DragonArmature.rotation.x = -90
					$DragonArmature/Skeleton/BoneAttachment/Head/CollisionShape.disabled = false
					
					var _delta = Global.Player.transform.origin - transform.origin
					_delta.y = 0
					_delta.z = -abs(_delta.z)
					move_and_slide(_delta.normalized() * SPEED * 2, Vector3.UP)
#					move_and_slide(Vector3(0, 0, -1) * SPEED * 2, Vector3.UP)
					
					
				State.Recover:
					headbangready = false
					if $Timers/Recover.is_stopped():
						$Timers/Recover.start()
						

func awaken():
	state = State.Recover
	
	
func fireState():
	var _delta = Global.Player.transform.origin - transform.origin
	$DragonArmature.rotation.y = Vector2(_delta.x, _delta.y).angle() + PI/2
	if shots >= maxshots:
		state = State.Recover
		shots = 0


func _on_Head_body_entered(body):
	
	if state == State.HeadBanging:
		if Global.isPlayer(body):
			Global.Player.knock(transform.origin, 14)
			motion = Vector3.ZERO
			
			
		elif body.name == "SpikesWall":
			health -= 1
			emit_signal("health_changed", health / maxhealth * 100)
			if health <= 0:
				parent.end()
			
		state = State.Recover
		$DragonArmature/Skeleton/BoneAttachment/Head/CollisionShape.disabled = true
		$DragonArmature.rotation.x = 0
		headbangready = false


func _on_Recover_timeout():
	if state == State.Recover:
		state = randi() % (State.HeadBanging+1)
		target = reference.transform.origin +\
				reference.get_node(State.keys()[state]).transform.origin
				

func _on_Fire_timeout():
	var f = fireball.instance()
	f.transform.origin = transform.origin +\
						$DragonArmature/Skeleton/BoneAttachment.transform.origin
						
	var _delta = Global.Player.transform.origin - transform.origin
	f.apply_impulse(Vector3.ZERO, _delta.normalized() * rand_range(300, 600))
	parent.add_child(f)
	
	shots += 1
	if shots < maxshots:
		$Timers/Fire.start()
	
	print("shooting")


func _on_HeadBang_timeout():
	headbangready = true
