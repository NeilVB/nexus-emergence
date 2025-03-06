extends Control

#var world1 : bool = true #LEVEL SYSTEM
#var world2 : bool = false


const WORLD1 = "res://world_1.tscn"
#const WORLD2 = "res://world_2.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicFxOrchestralGloomyMainMenuIntroduction.play()
	

func _on_start_pressed() -> void:
	#await LevelTransition.fade_to_black() #TO DO BUG WHEN CALLING IT AGAIN BECAUSE I SET IT TO QUEUE FREE(), WHY? BECAUSE YOU CAN'T CLICK CONTINUE ON GAME OVER SPLASH
	#LevelTransition.fade_from_black()
	get_tree().call_deferred("change_scene_to_file",WORLD1)


func _on_quit_pressed() -> void:
	get_tree().quit()
