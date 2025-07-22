extends PanelContainer

# Intended only to display visual health values, not keep track of health

var hp
var wiggle_amt : int = 5
@onready var AP : AnimationPlayer = $AnimationPlayer
@onready var bar : TextureProgressBar = $HBoxContainer/PanelContainer/ProgressBar
@onready var ends : TextureProgressBar = $HBoxContainer/PanelContainer/ProgressBarEnds

func display_health(_hp):
	hp = _hp
	bar.value = float(hp)
	ends.value = float(hp)
	if hp < 100:
		AP.play("wiggle")

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
	
