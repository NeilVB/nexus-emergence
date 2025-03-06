extends Control
@export var player: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func sfx():
	$Gameoverthing.play()
	
func _on_button_pressed() -> void:
	player.handle_respawn()  # Call the handle_hazard function of the player
	self.visible = false
