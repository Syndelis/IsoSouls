extends KinematicBody

var motion = Vector3.ZERO
var gravFall = 0
const GRAV = 60
const SPEED = 400
const FRIC = 0.2
const KNOCK = 50

enum AI {
	Aggro,
	Fall,
	Attack,
	Hit,
	Die,
	Ambush,
	Stick
}

var state = AI.Ambush

const maxhealth = 4.0
var health = maxhealth

var path = []
var path_node = 0

onready var nav = get_parent()
#onready var player = $"../../Player"
onready var tree = $AnimationTree

func _physics_process(delta):
	
	tree.set("parameters/Blend2/blend_amount", int(state == AI.Aggro))
	match state:
		
		AI.Ambush:
			pass
			
		AI.Fall:
			gravFall -= GRAV * delta
			if is_on_floor():
				gravFall = 0
				state = AI.Aggro
			
		AI.Stick:
			transform.origin = Global.Player.get_node("HumanArmature/Skeleton/Head")\
								.transform.origin + Global.Player.transform.origin
								
			$Armature/Skeleton.rotation.y = Global.Player.get_node("HumanArmature")\
								.rotation.y

		AI.Die:
			motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
			
		AI.Hit:
			if is_on_floor(): gravFall = 0
			else: gravFall -= GRAV * delta
			
			motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
			motion.y = gravFall
			
			if motion.length() < 0.5:
				state = AI.Aggro
				
		AI.Aggro:
			followPlayer(delta)
			
		AI.Attack:
			if $Timers/AttackTimer.time_left == 0:
				motion = Vector3.ZERO
				
				var diff = Global.Player.global_transform.origin - global_transform.origin
				$Armature/Skeleton.rotation.y = Vector2(diff.z, diff.x).angle()
				
				tree.set("parameters/attack_shot/active", 1)
				
				$Timers/AttackTimer.wait_time = rand_range(.7, 1.1)
				$Timers/AttackTimer.start()
				
			else:
				followPlayer(delta)
				
				
	tree.set("parameters/iw/blend_amount", motion.length())
	
	motion.y = gravFall
	motion = move_and_slide(motion, Vector3.UP)


func random3(minv, maxv):
	return Vector3(
		rand_range(minv, maxv),
		rand_range(minv, maxv),
		rand_range(minv, maxv)
	)


func followPlayer(delta):
	
	if not tree.get("parameters/attack_shot/active"):
		if path_node < path.size():
			var direction = path[path_node] - global_transform.origin
			if direction.length() < 1:
				path_node += 1
				
			else: motion = direction.normalized() * SPEED * delta
		
		if is_on_floor(): gravFall = 0
		else: gravFall -= GRAV * delta
		
		motion.y += gravFall
		
		$Armature/Skeleton.rotation.y = Vector2(motion.z, motion.x).angle()


func stickToPlayer():
	if Global.Player.trap(self):
		state = AI.Stick
		
	else:
		Global.Player.hit(transform.origin)
	
	
func freePlayer():
	state = AI.Hit
	Global.Player.untrap(self)
	
	
func hit(trans):
	
	if $Timers/IFrames.time_left == 0:
		health -= 1
		$HealthBar3D.set_health(health / maxhealth)
		
		if health <= 0:
			tree.set("parameters/state/current", 1) # Dead
			state = AI.Die
			collision_layer = 0b10000000000
			collision_mask = collision_layer
			$HealthBar3D.visible = false
			
			tree.active = false
			$AnimationPlayer.play("Slime_Death")
			yield($AnimationPlayer, "animation_finished")
			
			freePlayer()
			queue_free()
			
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


func _on_AttackRange_body_entered(body):
	
	if Global.isPlayer(body):
		if state == AI.Aggro:
			state = AI.Attack
			
		elif state == AI.Fall:
			stickToPlayer()


func _on_Hitbox_body_entered(body):
	if Global.isPlayer(body):
		stickToPlayer()


func _on_AmbushArea_body_entered(body):
	if state == AI.Ambush and Global.isPlayer(body):
		state = AI.Fall


func _on_AttackRange_body_exited(body):
	
	if state == AI.Attack and Global.isPlayer(body):
		state = AI.Aggro

func _on_StickDamageTimer_timeout():
	if state == AI.Stick:
		Global.Player.hit(transform.origin + random3(-1, 1))


func _on_StickMoveTimer_timeout():
	if state == AI.Stick:
		var i = Global.Player.ACC / Engine.get_frames_per_second() * 60
		Global.Player.motion += random3(-i, i)
