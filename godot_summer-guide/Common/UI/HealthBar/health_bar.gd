extends PanelContainer

# Intended only to display visual health values, not keep track of health

var wiggle_amt : int = 1
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var nums : Label = $MarginContainer/VBoxContainer/Numbers
@onready var bar : TextureProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/ProgressBar
@onready var ends : TextureProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/ProgressBarEnds
@onready var shield : TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/Shield

# === Custom Methods ===========================================================
## Health is out of 100. Displays as percentage of max_health
func display_hp(health : int, max_health : int = Globals.max_hp) -> void:
	var ratio : float = 100 / float(max_health)
	var hp_100 : float = float(health) * ratio				#Hp out of 100
	
	#Bar
	bar.value = hp_100
	ends.value = hp_100
	
	if health < max_health:
		animation_player.play("wiggle")
	else:
		animation_player.play("RESET")
	
	nums.text = str(health) + "/" + str(max_health)

func health_shield(toggle : bool) -> void:
	shield.visible = toggle

func up() -> void:
	if bar.value <= 99.0 && ends.value <= 99.0:
		bar.value += wiggle_amt
		ends.value += wiggle_amt
		
func down() -> void:
	if bar.value >= 1.0 && ends.value >= 1.0:
		bar.value -= wiggle_amt
		ends.value -= wiggle_amt
	
# === Built In =================================================================

func _ready() -> void:
	display_hp(Globals.hp)

func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
