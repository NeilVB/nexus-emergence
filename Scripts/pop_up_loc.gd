extends Marker2D

@export var damage_number : PackedScene
var fade_duration : float = 0.2

func _ready():
	randomize()

#CURRENT ISSUE TWEEN AND FADES OUT TOO EARLY
func popup(damage_value: int):
	#if damage_value <= 100: #FOR CRYSTALS
		#fade_duration = 0.2
	var damageNum = damage_number.instantiate()
	var label = damageNum.get_node("Label")
	label.text = str(damage_value)
	damageNum.position = global_position
	var tween = get_tree().create_tween()
	tween.tween_property(damageNum,"position",global_position + _get_direction(),fade_duration)
	tween.tween_property(damageNum, "modulate:a", 0, fade_duration)
	get_tree().current_scene.add_child(damageNum)

func _get_direction():
	return Vector2(randf_range(-1,1), randf()) * 16
