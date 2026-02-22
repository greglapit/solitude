extends Node2D

signal new_game_button_pressed

# === Custom Methods ===========================================================

func initialize() -> void:
	new_game_button_pressed.connect(get_parent()._on_main_menu_new_game_button_pressed)

# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_play_button_pressed() -> void:
	new_game_button_pressed.emit()


func _on_quit_button_pressed() -> void:
	var result : String = await ConfirmationWindow.prompt_user(self, "Are you sure?")
	if result == "yes":
		get_tree().quit()
		return
	else:
		return
			
