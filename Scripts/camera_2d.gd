extends Camera2D

@export var randomStrength: float = 4.0
@export var shakeFade: float = 5.0 #higher = faster fade

var RNG = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_shake():
	shake_strength = randomStrength

func _ready():
	if not EventManager.is_connected("shake_camera", Callable(self, "apply_shake")):
		EventManager.connect("shake_camera", Callable(self, "apply_shake"))

func _process(delta) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(RNG.randf_range(-shake_strength,shake_strength),RNG.randf_range(-shake_strength,shake_strength))
