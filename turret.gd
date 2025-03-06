extends Node2D

@export var BULLET : PackedScene

var target: Node2D = null

@onready var gunSprite = $GunSprite
@onready var rayCast = $RayCast2D
@onready var reloadTimer = $ReloadTimer
@export var BULLET_OFFSET_DISTANCE: float = 30.0

var is_exploded : bool = false
var total_bullets: int = 5

func _ready():
	await(get_tree().process_frame)
	target = find_target()

func _reload():
	gunSprite.play("reload")
	await gunSprite.animation_finished
	await get_tree().create_timer(3).timeout
	total_bullets = 5
	

func _physics_process(_delta: float) -> void:
	if is_exploded:  # Don't shoot if the gun is exploded
		return
	if target != null:
		var angle_to_target: float = global_position.direction_to(target.global_position).angle()
		rayCast.rotation = angle_to_target  # Rotate rayCast to face the target
		if rayCast.is_colliding():
			var collider = rayCast.get_collider()
			if collider and collider.is_in_group("Player"):
				gunSprite.rotation = angle_to_target
				if reloadTimer.is_stopped():
					shoot()

func shoot():
	if is_exploded:  # Don't shoot if the gun is exploded
		return
	rayCast.enabled = false
	if total_bullets <= 0:
		_reload()
	if BULLET && total_bullets > 0:
		gunSprite.play("shoot")
		total_bullets -= 1
		print(total_bullets)
		var bullet = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		var spawn_offset = Vector2(BULLET_OFFSET_DISTANCE, 0).rotated(gunSprite.rotation)
		bullet.global_position = global_position + spawn_offset
		bullet.global_rotation = rayCast.global_rotation
		await gunSprite.animation_finished
		gunSprite.play("default")
		
		
	reloadTimer.start()

func find_target():
	var new_target: Node2D = null
	if get_tree().has_group("Player"):
		new_target = get_tree().get_nodes_in_group("Player")[0]
	return new_target

func _on_reload_timer_timeout() -> void:
	rayCast.enabled = true



func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Hitzone":
		GameManager.shake_camera()
		gunSprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		gunSprite.modulate = Color.WHITE
		queue_free()

func sfx():
	$"Turretdestroy[hm]".play()
	GameManager.shake_camera()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Hitzone" && not is_exploded:
		is_exploded = true
		sfx()
		gunSprite.play("explode")
		await gunSprite.animation_finished
		gunSprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		gunSprite.modulate = Color.WHITE
		gunSprite.visible = false
