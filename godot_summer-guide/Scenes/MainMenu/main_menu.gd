extends Node2D


# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	await Globals.save_game()
	get_tree().quit()
