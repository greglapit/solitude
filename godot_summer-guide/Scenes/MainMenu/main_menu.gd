extends Node2DScene

@onready var cont_button : TextureButton = $CanvasLayer/MarginContainer/VBoxContainer/ContinueButton

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	var has_save : bool = FileAccess.file_exists("user://savegame.save")
	cont_button.visible = has_save
	return
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_play_button_pressed() -> void:
	var has_save : bool = FileAccess.file_exists("user://savegame.save")
	if has_save:
		var result : String = await ConfirmationWindow.prompt_user(self, "Erase previous save?")
		if result == "yes":
			var error : Error = DirAccess.remove_absolute("user://savegame.save")
			if error != OK:
				push_error("Failed to delete save file. Error code: ", error)
		else:
			return
	change_scn.emit("res://Scenes/Battle/battle.tscn", true)

func _on_continue_button_pressed() -> void:
	await Globals.load_save()
	var scene_handler : Node = get_parent()
	change_scn.emit(scene_handler.curr_scene_path, true)
	

func _on_quit_button_pressed() -> void:
	var result : String = await ConfirmationWindow.prompt_user(self, "Are you sure?")
	if result == "yes":
		get_tree().quit()
		return
	else:
		return
