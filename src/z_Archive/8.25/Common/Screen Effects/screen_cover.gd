extends ColorRect

@onready var AP : AnimationPlayer = $AnimationPlayer

signal screen_black

func fade_black():
	visible = true
	AP.play("fade_black")

func reset():
	AP.play("RESET")
	visible = false

func _ready():
	visible = false
	AP.animation_finished.connect(_on_AP_animation_finished)
	
func _on_AP_animation_finished(anim : StringName):
	match anim:
		"fade_black":
			screen_black.emit()
		_:
			AP.play("RESET")
			visible = false
