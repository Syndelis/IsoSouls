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
	Ambush
}

var state = AI.Ambush

const maxhealth = 6.0
var health = maxhealth

var path = []
var path_node = 0

export(NodePath) var nav_path
onready var nav = get_node(nav_path)
onready var tree = $AnimationTree

signal fightStart
signal health_changed(val)

func _physics_process(delta):
	
	tree.set("parameters/Blend2/blend_amount", 1)
	match state:
		
		AI.Ambush:
			pass
			
		AI.Fall:
			gravFall -= GRAV * delta
			if is_on_floor():
				gravFall = 0
				state = AI.Attack
			
		AI.Die:
			motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
			
		AI.Hit:
			if is_on_floor(): gravFall = 0
			else: gravFall -= GRAV * delta
			
			motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
			motion.y = gravFall
			
			if motion.length() < 0.5:
				state = AI.Attack
				
		AI.Aggro:
			followPlayer(delta)
			
		AI.Attack:
			if $Timers/AttackTimer.time_left == 0:
				
				var diff = Global.Player.global_transform.origin - global_transform.origin
				$Armature/Skeleton.rotation.y = Vector2(diff.z, diff.x).angle() + PI
				
				tree.set("parameters/attack_shot/active", 1)
				
				$Timers/AttackTimer.wait_time = rand_range(1.2, 1.7)
				$Timers/AttackTimer.start()
				
			else:
				followPlayer(delta)
				
	
	tree.set("parameters/iw/blend_amount", 1)
	
	motion.y = gravFall
	motion = move_and_slide(motion, Vector3.UP)
	

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
		
		$Armature/Skeleton.rotation.y = Vector2(motion.z, motion.x).angle() + PI
	

func dropKey():
	var body = $Armature/Skeleton/Body
	var key = body.get_node("Key")
	
	body.remove_child(key)
	key.transform = transform
	get_parent().add_child(key)


func hit(trans):
	
	if $Timers/IFrames.time_left == 0:
		health -= 1
		emit_signal("health_changed", health / maxhealth * 100)
#		$HealthBar3D.set_health(health / maxhealth)
		
		
		if health <= 0:
			tree.set("parameters/state/current", 1) # Dead
			state = AI.Die
			collision_layer = 0b10000000000
			collision_mask = collision_layer
#			$HealthBar3D.visible = false
			
			tree.active = false
			$AnimationPlayer.play("Slime_Death")
			yield($AnimationPlayer, "animation_finished")
			
			dropKey()
			queue_free()
			
		else:
#			$HealthBar3D.visible = true
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
		
		if state == AI.Fall:
			body.knock(transform.origin, 2)
			
		state = AI.Attack


func _on_Hitbox_body_entered(body):
	if Global.isPlayer(body):
		body.hit(transform.origin)


func _on_AmbushArea_body_entered(body):
	if state == AI.Ambush and Global.isPlayer(body):
		visible = true
		state = AI.Fall
		emit_signal("fightStart")


func _on_AttackRange_area_entered(area):
	if area.name == "KeyGamma":
		area.queue_free()
