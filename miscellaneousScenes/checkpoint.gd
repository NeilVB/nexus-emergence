extends Area2D

var showInteractionIcon = false
@onready var icon: TextureRect = $TextureRect
@onready var checkpoint_sprite: AnimatedSprite2D = $AnimatedSprite2D
var activated: bool = false
var respawn_offset : float = 10.0


func _ready():
	pass
	
func _process(delta):
	icon.visible = showInteractionIcon
	
	if showInteractionIcon && Input.is_action_just_pressed("Interact"):
		checkpoint_sprite.play("turn_on")
		await checkpoint_sprite.animation_finished
		checkpoint_sprite.play("activated")
		activated = true
		showInteractionIcon = false
		
		var player = get_player()  # Get the Player node
		if player:
			player.respawn_point = global_position + Vector2(0, -respawn_offset)

func get_player() -> Player:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0] as Player  # Return the first player found in the group
	return null
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player && !activated:
		showInteractionIcon = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player && !activated:
		showInteractionIcon = false
