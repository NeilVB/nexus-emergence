extends CharacterBody2D
class_name Player

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@export var anim_tree : AnimationTree
@export var Health : Control
@onready var Hitzone = $Hitzone
@onready var respawn_point: Vector2 = global_position
@onready var wall_speed: float = 300.0
@export var ghost_node: PackedScene

#particles
@onready var ground_dust = preload("res://Particles/land_dust.tscn")
var grounded = true


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var respawnOn : bool = false

var SPEED : float = 1000.0
const ACCELERATION = 1000.0
const FRICTION = 450.0               #Handles slowing down
const JUMP_VELOCITY = -400.0


var is_dead : bool = false
var jumpsMade = 0  
var attack_timer = 0.0  
var attack_combo = 0  
@export var max_health: int = 100  # Maximum health of the player
var current_health: int = 100  # Tracks the player's current health

@export var max_stamina: int = 100
var current_stamina: int = 100
var dash_consume: int = 40  #CELESTE STYLE, REGEN ONLY WHEN ON  FLOOR
var last_regen: float = 0
var regen_time : float = 1.0
var regen_amount: float = 15.0
var invincible: float = false

@export var dash_speed: float = 700.0
var directionDash: int = 1
@onready var dashEffectTimer = $DashEffectTimer
var can_dash: bool = false

var can_wall_jump : bool = false
var is_wall_sliding = false
const wall_slide_gravity = 100

var state_machine : AnimationNodeStateMachinePlayback
var move_state_machine : AnimationNodeStateMachinePlayback
var jump_state_machine : AnimationNodeStateMachinePlayback
var attack_state_machine : AnimationNodeStateMachinePlayback
var wall_jump : AnimationNodeStateMachinePlayback

func _ready():
	state_machine = anim_tree.get("parameters/playback")
	move_state_machine = anim_tree.get("parameters/Movement/playback")
	jump_state_machine = anim_tree.get("parameters/Jump/playback")
	attack_state_machine = anim_tree.get("parameters/Attack/playback")
	wall_jump = anim_tree.get("parameters/Wall_Jump/playback")

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	if not is_dead:
		handle_jump()
	var input_axis := Input.get_axis("Left", "Right")
	if not is_dead:
		handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	update_animations(input_axis)
	handle_attack()
	
	handle_dash()
	regen_stamina(delta)
	direction_Dash(input_axis)
	 
	handle_checkpoint(respawn_point)
	
	handle_wall_animation()
	handle_wall_jump()
	handle_wall_slide(delta)
	move_and_slide()
	if current_health <= 0:
		EventManager.emit_signal("game_over")
		handle_death()

func handle_checkpoint(position : Vector2) -> void:
	respawn_point = position

func handle_wall_slide(delta):
	if is_on_wall_only() and !is_on_floor():
		if Input.is_action_pressed("Right") or Input.is_action_pressed("Left"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)

func handle_wall_animation():
	if is_on_wall_only() and not is_on_floor():
		anim.play("on_wall")  # Play the wall animation
func handle_wall_jump():
	if can_wall_jump and Input.is_action_just_pressed("Up") and is_on_wall_only():
		var wall_normal: Vector2 = get_wall_normal()
		if wall_normal:
			can_wall_jump = true
			velocity.x = wall_normal.x * wall_speed
			velocity.y = JUMP_VELOCITY * 1.1

func regen_stamina(_delta : float):
	last_regen += _delta
	if last_regen >= regen_time and current_stamina < max_stamina:
		last_regen = 0.0
		if current_stamina < 100:
			var new_stamina = min(current_stamina + regen_amount, max_stamina)
			current_stamina = new_stamina
			Health.regen_stamina(current_stamina)
			print("stamina: ", current_stamina)
	#time_since_last_regen += _delta
	## If enough time has passed since the last regeneration
	#if time_since_last_regen >= regen_delay and current_stamina < max_stamina:
		#time_since_last_regen = 0.0  # Reset the timer
		#if current_stamina < max_stamina:
			#var new_stamina = min(current_stamina + regen_rate, max_stamina)
			#if time_since_last_regen >= regen_delay:
				#time_since_last_regen = 0.0  
			#if new_stamina != current_stamina:
				#current_stamina = new_stamina
				#Health.change_stamina(current_stamina)  # Sync with HUD
				#print("Stamina regenerated:", current_stamina)
			#else:
				## If stamina is already full, ensure the HUD shows full stamina
				#if current_stamina != max_stamina:
					#current_stamina = max_stamina
					#Health.change_stamina(current_stamina)  # Sync with HUD
					#print("Stamina is full")

func dash_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, $AnimatedSprite2D.scale)
	if directionDash == 1:
		ghost.scale.x = abs(ghost.scale.x)  # Make sure the ghost faces right
	elif directionDash == -1:
		ghost.scale.x = -abs(ghost.scale.x)  # Flip the ghost to face left
	get_tree().current_scene.add_child(ghost)

func _on_dash_effect_timer_timeout() -> void:
	dash_ghost()

func direction_Dash(value : float):
	directionDash = sign(value)
	
func handle_dash():
	if current_stamina < dash_consume:
		return
	if Input.is_action_just_pressed("Dash") and can_dash and not is_on_floor():
		$"Dash[hm]".play()
		GameManager.shake_camera() 
		dashEffectTimer.start()
		can_dash = false
		decrease_stamina(dash_consume)
		dash_ghost()
		state_machine.travel("dash")
		velocity.x = directionDash * dash_speed
		await get_tree().create_timer(0.15).timeout
		dashEffectTimer.stop()
		invincible = false
	if Input.is_action_just_pressed("Dash"):
		$"Dash[hm]".play()
		GameManager.shake_camera() 
		dashEffectTimer.start()
		can_dash = false
		decrease_stamina(dash_consume)
		dash_ghost()
		state_machine.travel("dash")
		velocity.x = directionDash * dash_speed
		await get_tree().create_timer(0.15).timeout
		dashEffectTimer.stop()
		invincible = false

func handle_death():
	is_dead = true
	respawnOn = true
	if is_dead:
		state_machine.travel("Death")
	await get_tree().create_timer(1).timeout
	if is_on_floor():
		#get_tree().paused = true
		print("PLAYER IS DEAD!")
		$AnimatedSprite2D.visible = true

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jump():
	can_dash = true
	if is_on_floor():
		can_wall_jump = true #WALLJUMP
		jumpsMade = 0
	
	# Perform the first jump
	if Input.is_action_just_pressed("Up") and jumpsMade == 0:
		$"Jump[hm]".play()
		velocity.y = JUMP_VELOCITY
		jumpsMade = 1 #1  # First jump made
	
	# Perform the second jump (double jump) if already in the air
	elif Input.is_action_just_pressed("Up") and jumpsMade == 1:
		$"Jump[hm]".play()
		velocity.y = JUMP_VELOCITY
		jumpsMade = 2  #2 # Double jump made
	
	if Input.is_action_just_released("Up") and velocity.y < JUMP_VELOCITY / 2:
		velocity.y = JUMP_VELOCITY / 2

func apply_friction(input_axis, delta):
	if input_axis == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func handle_acceleration(input_axis, delta):
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, SPEED * input_axis, ACCELERATION * delta)

func update_animations(input_axis):
		# Prioritize wall animation
	if is_on_wall_only() and not is_on_floor():
		wall_jump.travel("on_wall")
		state_machine.travel("Wall_Jump")
	
	if input_axis == 0:
		if abs(velocity.x) > 0.1:  # Use a small threshold to prevent floating-point errors
			move_state_machine.travel("Slow_Down")
		else:
			move_state_machine.travel("Idle")
	else:
		move_state_machine.travel("Run")
	
	if velocity == Vector2.ZERO:
		set_motion(false)
	else:
		set_motion(true)
	
	#particles
	if grounded == false and is_on_floor() == true and not is_dead:
		var instance = ground_dust.instantiate()
		instance.global_position = $land_dust.global_position
		get_parent().add_child(instance)
	grounded = is_on_floor()
		
	
	if !is_wall_sliding:
		if not is_on_floor() && !is_wall_sliding:
			if velocity.y > 0:
				state_machine.travel("Jump") 
			else:
				state_machine.travel("Jump")
		else:
			state_machine.travel("Movement")
	if input_axis < 0:
		$AnimatedSprite2D.flip_h = true
		#COLLISION FLIPPP
		$CollisionShape2D2.position.x = 4.59
		$Hurtbox/HurtboxCollision.position.x = 4.59
		Hitzone.scale.x = -1 
	elif input_axis > 0:
		Hitzone.scale.x = 1
		$CollisionShape2D2.position.x = -4.59
		$Hurtbox/HurtboxCollision.position.x = -4.59
		$AnimatedSprite2D.flip_h = false

func handle_attack():
	if attack_timer > 0:
		attack_timer -= get_process_delta_time()  
		return
	if Input.is_action_just_pressed("Attack") and is_on_floor():
		if attack_combo == 0:  
			play_attack("1") 
			attack_combo = 1  
		elif attack_combo == 1: 
			play_attack("2") 
			attack_combo = 0  
		attack_timer = 0.3 

func play_attack(type : String):
	attack_state_machine.travel("attack" + type)
	state_machine.travel("Attack")
	set_speed(0) #TO-DO REFINE THE ATTACK MECHANICS [JUMP WHILE ATTACK, I-FRAMES, RUNNING ATTACK]

func set_speed(value : float = 300.0):
	SPEED = value

func set_motion(value : bool):
	anim_tree.set("parameters/Movement/conditions/can_run", value)
	anim_tree.set("parameters/Movement/conditions/is_stopped", not value)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_dead || invincible:
		return
	if area is ToxicWater:
		sprite.modulate = Color.RED
		apply_damage(100)
		$"PlayerHurt[hm]".play()
		await get_tree().create_timer(0.5).timeout
		$AnimatedSprite2D.visible = false
		sprite.modulate = Color.WHITE
	if area is Bullet:
		if invincible:
			return 
		GameManager.frameFreeze(0.05, 0.5)
		var knockback_direction = (global_position - area.global_position).normalized()
		velocity += knockback_direction * 300  # Adjust the knockback strength
		sprite.modulate = Color.RED
		apply_damage(10)
		$"PlayerHurt[hm]".play()
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
	#if area is HazardZone: 
		#global_position = respawn_point
	elif area.name == "DamagePlayer": #WORKED JUST SWITCHED TO ELSE IF
		GameManager.frameFreeze(0.05, 0.5)
		var knockback_direction = (global_position - area.global_position).normalized()
		velocity += knockback_direction * 300  # Adjust the knockback strength
		sprite.modulate = Color.RED
		apply_damage(10)
		$"PlayerHurt[hm]".play()
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE

func decrease_stamina(amount: int):
	invincible = true
	current_stamina -= amount
	current_stamina = clamp(current_stamina, 0, max_stamina)  
	if current_stamina != null:
		Health.change_stamina(-amount) 

func apply_damage(amount: int):
	GameManager.shake_camera() 
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)  # Prevents health from going out of bounds
	
	if Health != null:
		Health.change_health(-amount)  # Update the health bar
	
func handle_respawn():
	global_position = respawn_point
	get_tree().paused = false
	$AnimatedSprite2D.visible = true
	state_machine.travel("Movement")
	if is_dead && respawnOn:
		current_health = max_health
		Health.change_health(current_health)  # Update the health bar
		Health.respawn_flag(true)
		is_dead = false
