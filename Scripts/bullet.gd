extends Area2D
class_name Bullet

const RIGHT = Vector2.RIGHT
@export var SPEED: int = 200
var has_collided = false
var has_hit_player = false
var collision_shape : CollisionShape2D

func _physics_process(delta: float) -> void:
	if has_collided:
		return
	var movement = RIGHT.rotated(rotation) * SPEED * delta
	global_position += movement

func _ready():
	collision_shape = $CollisionShape2D
	$AnimatedSprite2D.play("default")
	var pitch_values = [1,1.2,1.3,1.4]
	var random_pitch = pitch_values[randi() % pitch_values.size()]
	$LasrGunPlasmaRifleFire03.pitch_scale = random_pitch
	$LasrGunPlasmaRifleFire03.play()

func destroy():
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _disable_collision():
	collision_shape.disabled = true



func _on_body_entered(body: Node2D) -> void:
	if body.name == "TileMapLayer":
		has_collided = true
		call_deferred("_disable_collision")
		$AnimatedSprite2D.play("impact")
		await $AnimatedSprite2D.animation_finished
		destroy()
	#print("Collided with:", body.name)
	#if body.name == "Player" and not has_hit_player:
		#has_hit_player = true
		#has_collided = true
		#call_deferred("_disable_collision")
		#print("Bullet hit the player!")
		#$AnimatedSprite2D.play("impact")
		#await $AnimatedSprite2D.animation_finished
		##GameManager.shake_camera() #Shake Cam
		#destroy()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox" and not has_hit_player:
		has_hit_player = true
		has_collided = true
		call_deferred("_disable_collision")
		print("Bullet hit the player!")
		$AnimatedSprite2D.play("impact")
		await $AnimatedSprite2D.animation_finished
		#GameManager.shake_camera() #Shake Cam
		destroy()
