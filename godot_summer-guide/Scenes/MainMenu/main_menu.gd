extends Node2DScene

@onready var cont_button : TextureButton = $CanvasLayer/MarginContainer/VBoxContainer/ContinueButton

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	var has_save : bool = FileAccess.file_exists("user://savegame.save")
	cont_button.visible = has_save
	return
	
func _input(_event: InputEvent) -> void:
	if _event.is_action_pressed("ui_cancel") and !get_parent().find_child("ConfirmationWindow"):
		_on_quit_button_pressed()

# === Signals ==================================================================

func _on_play_button_pressed() -> void:
	var has_save : bool = FileAccess.file_exists("user://savegame.save")
	if has_save:
		var result : String = await ConfirmationWindow.prompt_user(self, "Erase previous save?")
		if result == "Yes":
			Globals.delete_save()
		else:
			return
	change_scn.emit(Globals.scenes.START_CUTSCENE, true, false)
	Globals.load_all_resources()

func _on_continue_button_pressed() -> void:
	Globals.load_all_resources()
	await Globals.load_save()
	var scene_handler : Node = get_parent()
	change_scn.emit(scene_handler.curr_scene_id, true, false)
	

func _on_quit_button_pressed() -> void:
	var result : String = await ConfirmationWindow.prompt_user(self, "Exit game?")
	if result == "Yes":
		get_tree().quit()
		return
	else:
		return
