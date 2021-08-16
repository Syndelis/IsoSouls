extends KinematicBody

var motion = Vector3.ZERO
export var GRAV = 60
export var MAX_SPEED = 12.5
export var JUMP = -600
export var ACC = 150
export var FRIC = 0.2
export var ROLL_MULT = 2
export var KNOCK = 50

export(int, FLAGS, "Alpha", "Beta", "Gamma") var keys = 0

onready var tree = $AnimationTree
onready var VP = get_viewport()

var maxhealth = 10.0
var health = maxhealth

var gravFall = 0
var trapped = false

var stickySlime = null
export var has_sword = false

const Actions = {
	Roll="parameters/roll_shot/active",
	Attack="parameters/attack_shot/active",
	Jump="parameters/jump_shot/active"
}

enum State {Alive, Hit, Cutscene, Dead}
var state = State.Alive

signal health_changed(health)
signal cutscene(started)

func _ready():
	emit_signal("health_changed", health/maxhealth * 100)
	
	if not has_sword:
		$HumanArmature/Skeleton/RHand/Sword.visible = false


func _physics_process(delta):
	
	var inp = Vector3.ZERO
	
	if state != State.Dead and state != State.Cutscene:
		
		if not tree.get("parameters/hit_shot/active"):
			state = State.Alive
		
		var in_action = false
		for a in Actions:
			in_action = in_action or tree.get(Actions[a])
			
		if tree.get(Actions.Attack):
			motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
		
		if not in_action:
			if  Input.is_action_just_pressed("roll") and state != State.Hit and not trapped:
				tree.set(Actions.Roll, true)
				
				# Roll into direction ------------------------
				inp = ROLL_MULT * motion.normalized()
				motion += inp * ACC * delta
				var v = Vector2(motion.x, motion.z).clamped(MAX_SPEED * 1.2)
				
				print(motion.length(), " ", v.length())
				motion.x = v.x
				motion.z = v.y
				print(motion.length())
				# --------------------------------------------
				
				# Roll into mouse ----------------------------
				# TRY HIGHER ROLL_MULT
				#var dir = VP.get_mouse_position() - (VP.size/2)
				#dir = dir.normalized() * ROLL_MULT
				
				#inp.x = dir.x
				#inp.z = dir.y
				
				#motion = inp * ACC * delta
				# --------------------------------------------
			
			elif Input.is_action_just_pressed("attack") and has_sword:
				motion = Vector3.ZERO
				tree.set(Actions.Attack, true)
				
				
			elif Input.is_action_just_pressed("interact"):
				
				var bodies = $Interacter.get_overlapping_bodies()
				
				for body in bodies:
					if body.is_in_group("Interactable"):
						body.interact()
			
			else:
				inp.x = (Input.get_action_strength("move_right") -\
						 Input.get_action_strength("move_left"))
				
				inp.z = (Input.get_action_strength("move_down") -\
						 Input.get_action_strength("move_up"))
				
				var norm = inp.normalized()
				inp.x = min(abs(inp.x), abs(norm.x)) * sign(norm.x)
				inp.z = min(abs(inp.z), abs(norm.z)) * sign(norm.z)
				
				motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
				motion += inp * ACC * delta
		
		
		if is_on_floor(): gravFall = 0
		else: gravFall -= GRAV * delta
		
		var l = motion.length()
		var speed = l / MAX_SPEED
		tree.set("parameters/iwr_blend/blend_amount", speed*2 - 1)
		tree.set("parameters/walk_scale/scale", min(1, speed * 2))
		tree.set("parameters/run_scale/scale", speed * 1.15)
		
		if l > 0.5 and state != State.Hit:
			$HumanArmature.rotation.y = Vector2(motion.z, motion.x).angle()
			
		else:
			tree.set("iwr_blend", -1)
	
	else:
		motion = motion.linear_interpolate(Vector3.ZERO, FRIC)
		
		if state == State.Dead and Input.is_action_just_pressed("reset"):
			Global.resetGame()
		
	if state == State.Cutscene:
		tree.set("parameters/iwr_blend/blend_amount", -1)
	
	motion.y = gravFall * int(state != State.Dead)
	motion = move_and_slide(motion, Vector3.UP)


func isDead():
	return health <= 0


func hit(trans, dmg=1):
	
	if not tree.get(Actions.Roll) and state != State.Dead:
		health -= dmg
		emit_signal("health_changed", health/maxhealth * 100)
		
		state = State.Hit
		if health <= 0: kill()
		
		knock(trans)
		
		if tree.get(Actions.Attack):
			tree.set(Actions.Attack, 0)
			$HumanArmature/Skeleton/RHand/Sword/HitBox/CollisionShape.disabled = true
			
		tree.set("parameters/hit_shot/active", 1)
		
		return true
		
	return false


func knock(trans, mult=1):
	var dir = (transform.origin - trans)
	dir.y = 0
	
	motion = dir.normalized() * KNOCK * mult


func startCutscene():
	emit_signal("cutscene", true)
	state = State.Cutscene

func resetState():
	emit_signal("cutscene", false)
	state = State.Alive


func kill():
	state = State.Dead
	tree.set("parameters/status/current", 1)
	health = 0
	emit_signal("health_changed", health/maxhealth * 100)
	
	if stickySlime:
		stickySlime.state = stickySlime.AI.Hit
		stickySlime.hit(transform.origin)
		untrap(stickySlime)


func heal(amnt):
	
	health = min(health + amnt, maxhealth)
	emit_signal("health_changed", health/maxhealth * 100)


func trap(who):
	
	if not stickySlime:
		trapped = true
		stickySlime = who
		return true
		
	else: return false

func untrap(who):
	
	if stickySlime == who:
		trapped = false
		stickySlime = null
	
	
func equip(what, where):
	what.get_parent().remove_child(what)
	print(where)
	get_node("HumanArmature/Skeleton/" + where + "/Anchor").add_child(what)
	maxhealth += 2
	health += 2
	
	emit_signal("health_changed", health/maxhealth * 100)


func giveSword():
	has_sword = true
	$HumanArmature/Skeleton/RHand/Sword.visible = true
	
	
func has(key):
	return keys & key
	

func give(key):
	keys |= key


func _on_HitBox_body_entered(body):
	if body.is_in_group("Enemy"):
		body.hit(transform.origin)
		
		if body.is_in_group("Slime"):
			
			if randf() < 0.6: body.freePlayer()
