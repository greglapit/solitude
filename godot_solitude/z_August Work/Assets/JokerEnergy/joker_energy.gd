extends Label

@onready var AP : AnimationPlayer = $AnimationPlayer

func flash():
	AP.play("flash_text")
