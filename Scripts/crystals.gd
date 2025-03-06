extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var value: int = 100
@onready var popUpLoc = $popUpLoc 

func _ready():
	anim.play("idle")

#note: make sure it's in if statement so it doesn't disappear when colliding with ground
func _on_body_entered(body: Node2D) -> void: 	
	if body.name == "Player":
		anim.play("collected")
		var tween = create_tween()
		$AudioStreamPlayer2D.play()
		popUpLoc.popup(100)
		GameManager.crystal_collected(value)
		tween.tween_property(self, "position", position + Vector2(0, -30), 0.2)
		tween.tween_property(self, "modulate:a",0.0, 0.2)
		tween.tween_callback(self.queue_free)
