extends Area2D

@export var left : int
@export var right : int
@export var top : int
@export var bottom : int

@export var camera: Camera2D
@export var BossMusicFile: AudioStream
@export var BossHpBar: Control
var camera_locked = false  # Flag to prevent repeated setting of limits
var audio_player: AudioStreamPlayer2D  # Declare the audio player

func _ready():
	# Initialize the AudioStreamPlayer2D
	audio_player = AudioStreamPlayer2D.new()
	add_child(audio_player)  # Add it as a child of the current node
	# Set the stream for the audio player (this can be done once)
	audio_player.stream = BossMusicFile

func _on_body_entered(body: Node2D) -> void:
	if not camera_locked && body is Player:
		audio_player.play()
		BossHpBar.show()
		camera.limit_left = left
		camera.limit_right = right
		camera.limit_top = top
		camera.limit_bottom = bottom
		camera_locked = true  # Set the flag to true so we don't repeat this
