extends KinematicBody

var path = []
var path_node = 0

var motion = Vector3.ZERO
var gravFall = 0
const GRAV = 60
const SPEED = 600
const FRIC = 0.2
const KNOCK = 50

enum AI {
	Idle,
	Aggro,
	Attack,
	Hit,
	Die,
	Spawn,
	Ambush
}

var state = AI.Ambush

const maxhealth = 4.0
var health = maxhealth

onready var nav = get_parent()

onready var tree = $AnimationTree

func _physics_process(delta):
	
	motion.y = 0
	
	if is_on_floor(): gravFall = 0
	else: gravFall -= GRAV * delta
		
	match state:
		
		AI.Ambush:
			tree.set("parameters/state/current", 1)
		
		AI.Idle:
			motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
			
		AI.Aggro:
			followPlayer(delta)
				
		AI.Attack:
			if $Timers/AttackTimer.time_left == 0:
				motion = Vector3.ZERO
				
				var diff = Global.Player.global_transform.origin - global_transform.origin
				$SkeletonArmature.rotation.y = Vector2(diff.z, diff.x).angle()
				
				tree.set("parameters/attack_shot/active", 1)
				
				$Timers/AttackTimer.wait_time = rand_range(.7, 1.1)
				$Timers/AttackTimer.start()
				
			else:
				followPlayer(delta)
				
		AI.Hit:
			motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
			if motion.length() < 0.5:
				state = AI.Aggro
			
		AI.Die:
			motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
			
		AI.Spawn:
			if not tree.get("parameters/spawn_shot/active"):
				state = AI.Idle
				tree.set("parameters/state/current", 0) # Alive
				health = maxhealth
			
	
	tree.set("parameters/iw/blend_amount", motion.length())
	
	motion.y = gravFall
	motion = move_and_slide(motion, Vector3.UP)
	
	
func followPlayer(delta):
	
	if not tree.get("parameters/attack_shot/active"):
		if path_node < path.size():
			var direction = path[path_node] - global_transform.origin
			if direction.length() < 1:
				path_node += 1
				
			else: motion = direction.normalized() * SPEED * delta
			
		$SkeletonArmature.rotation.y = Vector2(motion.z, motion.x).angle()


func hit(trans):
	
	if $Timers/IFrames.time_left == 0 and state != AI.Spawn:
		health -= 1
		$HealthBar3D.set_health(health / maxhealth)
		
		if health <= 0:
			tree.set("parameters/state/current", 1) # Dead
			state = AI.Die
			collision_layer = 0b10000000000
			collision_mask = collision_layer
			$HealthBar3D.visible = false
			
			$Timers/Respawn.start()
			
		else:
			$HealthBar3D.visible = true
			state = AI.Hit
		
		var dir = (transform.origin - trans)
		dir.y = 0
		
		if not tree.get("parameters/attack_shot/active"):
			motion = dir.normalized() * KNOCK
		
		$Timers/IFrames.start()


func _on_FollowTimer_timeout():
	
	if state in [AI.Aggro, AI.Attack]:
		path = nav.get_simple_path(global_transform.origin, Global.Player.global_transform.origin)
		path_node = 0


func _on_Hearing_body_entered(body):
	
	if Global.isPlayer(body):
		if state == AI.Idle:
			state = AI.Aggro
			
		elif state == AI.Ambush:
			tree.set("parameters/spawn_shot/active", 1)
			state = AI.Spawn


func _on_AttackRange_body_entered(body):
	
	if state == AI.Aggro and Global.isPlayer(body):
		state = AI.Attack


func _on_AttackRange_body_exited(body):
	
	if state == AI.Attack and Global.isPlayer(body):
		state = AI.Aggro


func _on_AttackHitBox_body_entered(body):
	if Global.isPlayer(body):
		body.hit(transform.origin)


func _on_Respawn_timeout():
	tree.set("parameters/spawn_shot/active", 1)
	state = AI.Spawn
	collision_layer = 0b10000000001
	collision_mask = collision_layer
