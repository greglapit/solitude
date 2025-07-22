extends TextEdit

@onready var AP : AnimationPlayer = $AnimationPlayer

func display_text(pattern : String):
	text = pattern
	AP.play("RESET")
	AP.play("fade_text")
	
func _ready() -> void:
	AP.play("fade_text")
