extends Control

@onready var label = $CanvasLayer/Label

var current_score = 0

func _ready():
	EventManager.connect("crystal_collected", _on_event_crystal_collected)
	$CanvasLayer/Label.text = str(current_score).pad_zeros(10)

func update_score_label(value) -> void:
	label.text = str(value).pad_zeros(10)

func _on_event_crystal_collected(value : int) -> void:
	current_score += 100
	#label.text = str(value)
	update_score_label(value)
