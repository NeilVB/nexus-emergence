extends Node
#THIS WILL SERVE AS GLOBAL NODE

var total_crystals: int = 0

func crystal_collected(value : int):
	total_crystals += value
	EventManager.emit_signal("crystal_collected", total_crystals)
	
func shake_camera():
	EventManager.emit_signal("shake_camera")

func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1.0

func game_over(): 
	EventManager.emit_signal("game_over")

func level_finished(): 
	EventManager.emit_signal("level_finished")
