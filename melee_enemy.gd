extends CharacterBody2D

@export var SPEED: int = 100
@export var CHASE_SPEED: int = 150
@export var ACCELERATION: int = 300
@export var value: int = 1000 #For Score

var speed = -60.0
@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var popUpLoc = $popUpLoc 

var facing_right = false
var was_on_wall = false
var pointsGot : bool = false

var enemyHP: int = 50

func _ready():
	animation.play("walk")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if !$RayCast2D.is_colliding() && is_on_floor():
		flip()
	
	was_on_wall = is_on_wall()
	
	if is_on_wall() and not was_on_wall:
		flip()
	
	velocity.x = speed
	move_and_slide()
	
func flip():
	facing_right = !facing_right
	
	scale.x =abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1
	
	

func _on_wall_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		flip()


func death():
	#if enemyHP < 0:
	#call_deferred("_disable_collision")
	if not pointsGot:
		call_deferred("disable_collision")
		pointsGot = true  # Prevent double allocation immediately
		$AnimatedSprite2D.play("death")
		GameManager.frameFreeze(0.05, 0.2)
		#dd$"JdSherbert-PixelUiSfxPack-Error2(square)".play()
		await $AnimatedSprite2D.animation_finished
		getPoints()  # Call points function only once
		queue_free()

func getPoints():
	GameManager.crystal_collected(value)

func disable_collision():
	var collision_shape = $DamagePlayer/CollisionShape2D
	collision_shape.disabled = true

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Hitzone": 
		var knockback_direction = (global_position - body.global_position).normalized()
		velocity += knockback_direction * 90  # Adjust the knockback strength
		#enemyHP -= 50
		death()
		GameManager.shake_camera()
		animation.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		animation.modulate = Color.WHITE


func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	if pointsGot:
		return
	if area.name == "Hitzone":  
		popUpLoc.popup(1000)
		var knockback_direction = (global_position - area.global_position).normalized()
		velocity += knockback_direction * 90  # Adjust the knockback strength
		#enemyHP -= 50
		death()
		GameManager.shake_camera()
		animation.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		animation.modulate = Color.WHITE

#
#func _on_damage_player_body_entered(body: Node2D) -> void:
	#if body.name == "Player":
		#GameManager.shake_camera() 
