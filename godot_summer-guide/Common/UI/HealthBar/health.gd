extends PanelContainer

# Intended only to display visual health values, not keep track of health

var hp : float = 100
var wiggle_amt : int = 1
@onready var AP : AnimationPlayer = $AnimationPlayer
@onready var nums : Label = $MarginContainer/VBoxContainer/Numbers
@onready var bar : TextureProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/ProgressBar
@onready var ends : TextureProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/ProgressBarEnds
@onready var shield : TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/Shield

# === Custom Methods ===========================================================
func display_health(health : float, max_health : int = 20) -> void:
	hp = health
	
	#Bar
	bar.value = hp
	ends.value = hp
	if hp < 100:
		AP.play("wiggle")
	
	var label_health : int = int(hp / (100 / float(max_health)))
	nums.text = str(label_health) + "/" + str(max_health)

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
	display_health(hp)

func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
