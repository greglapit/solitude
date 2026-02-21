extends Node2D

signal new_game_button_pressed

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_play_button_pressed() -> void:
	new_game_button_pressed.emit()


func _on_quit_button_pressed() -> void:
	await Globals.save_game()
	get_tree().quit()
