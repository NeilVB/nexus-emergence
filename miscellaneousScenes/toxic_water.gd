extends Area2D
class_name ToxicWater

var player_in_water : bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("default")


func _on_event_toxic_death():
	call_deferred("_disable_collision")

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox" && !player_in_water:
		player_in_water = true
		death()
		

func _disable_collision():
	$CollisionShape2D.disabled = true

func death():
	if player_in_water:
		$AnimatedSprite2D.play("default")
		player_in_water = false
