extends Node2D

@onready var game_over = $CanvasLayer/Game_Over_Splash
@onready var level_start: CanvasLayer = $Level_Start
@onready var level_won_menu = $CanvasLayer/Game_Over_Splash

func _ready() -> void:
	game_over.hide()
	#$"MusicFxChiptuneSquareFuturisticArcadeScifi(1)".play()
	EventManager.game_over.connect(_game_over)
	EventManager.level_finished.connect(show_level_finished)

func show_level_finished():
	level_won_menu.show()

func _game_over():
	game_over.show()
