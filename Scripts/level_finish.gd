extends Area2D

@export var next_level: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if next_level == null:
		return 
	if body.name == "Player": 
		EventManager.level_finished.emit()
		get_tree().paused = true
		#call_deferred("change_scene")


func change_scene() -> void:
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
