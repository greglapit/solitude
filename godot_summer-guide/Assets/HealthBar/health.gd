extends PanelContainer

# Intended only to display visual health values, not keep track of health

var hp
var wiggle_amt : int = 1
@onready var AP : AnimationPlayer = $AnimationPlayer
@onready var nums : Label = $VBoxContainer/Numbers
@onready var bar : TextureProgressBar = $VBoxContainer/HBoxContainer/PanelContainer/ProgressBar
@onready var ends : TextureProgressBar = $VBoxContainer/HBoxContainer/PanelContainer/ProgressBarEnds
@onready var shield : TextureRect = $VBoxContainer/HBoxContainer/PanelContainer/Shield

func display_health(_hp : float):
	hp = _hp
	
	#Bar
	bar.value = hp
	ends.value = hp
	if hp < 100:
		AP.play("wiggle")
	
	# Number
	nums.text = str(int(round(hp / 5))) + "/20"

func health_shield(toggle : bool):
	shield.visible = toggle

func up():
	if bar.value <= 99.0 && ends.value <= 99.0:
		bar.value += wiggle_amt
		ends.value += wiggle_amt
		
func down():
	if bar.value >= 1.0 && ends.value >= 1.0:
		bar.value -= wiggle_amt
		ends.value -= wiggle_amt

func _ready() -> void:
	AP.play("wiggle")
	
