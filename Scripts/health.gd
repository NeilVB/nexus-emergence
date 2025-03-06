extends Control 

@onready var hpBar1 = $HPBAR2
@onready var hpBar2 = $HPBAR
@onready var staminaBar2 = $StaminaBAR
@onready var staminaBar = $StaminaBAR2
@export var max_health: int = 100
var is_respawning = false
 
func regen_stamina(newValue):
	staminaBar2.value = newValue

func change_stamina(newValue):
	var oldValue = staminaBar2.value
	var styleBox : StyleBox = staminaBar.get_theme_stylebox("fill")
	
	if newValue > 0:
		staminaBar.value = oldValue + newValue
		styleBox.bg_color = Color("1a340b")
		_catch_up_change(staminaBar2,newValue)
	elif newValue < 0:
		staminaBar2.value = oldValue + newValue
		styleBox.bg_color = Color("ca00")
		_catch_up_change(staminaBar,newValue)
	

func change_health(newValue):
	var oldValue = hpBar2.value
	var styleBox : StyleBox = hpBar1.get_theme_stylebox("fill")
	if newValue > 0:
		hpBar1.value = oldValue + newValue
		styleBox.bg_color = Color("1a340b")
		_catch_up_change(hpBar2, newValue)
	elif newValue < 0:
		hpBar2.value = oldValue + newValue
		styleBox.bg_color = Color("ca00")
		_catch_up_change(hpBar1, newValue)
		
	hpBar1.add_theme_stylebox_override("fill",styleBox)
	
func _catch_up_change(hpBar, changeValue):
	var time = 0.05
	if is_respawning:
		if changeValue == max_health:  # If the change is to reset health to max
			time = 0.01  # Faster update for respawn
		elif hpBar.value == max_health:  # If health is already full, speed up animation
			time = 0.01  # Even faster update to show full health
	for i in abs(changeValue):
		await get_tree().create_timer(time).timeout
		if changeValue < 0: hpBar.value -= 1
		elif changeValue > 0: hpBar.value += 1
	respawn_flag(false)

func respawn_flag(state: bool):
	is_respawning = state
