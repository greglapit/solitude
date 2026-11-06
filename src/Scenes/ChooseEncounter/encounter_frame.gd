class_name EncounterFrame
extends AnimatedSprite2D

const encounter_frame_scene : PackedScene = preload("res://Scenes/ChooseEncounter/encounter_frame.tscn")

const sprite_frames_dict : Dictionary = {
	Globals.scenes.BATTLE : "res://Scenes/ChooseEncounter/Art/EncounterFrames/battle_sprite_frames.tres",
	Globals.scenes.KOD : "res://Scenes/ChooseEncounter/Art/EncounterFrames/kod_sprite_frames.tres",
	Globals.scenes.QOD : "res://Scenes/ChooseEncounter/Art/EncounterFrames/qod_sprite_frames.tres"
}

var scn : Globals.scenes
signal clicked

# === Custom Methods ===========================================================
static func new_frame(_frame : Globals.scenes) -> EncounterFrame:
	var encounter_frame : EncounterFrame = encounter_frame_scene.instantiate()
	encounter_frame.scn = _frame
	return encounter_frame

# === Built In =================================================================

func _ready() -> void:
	sprite_frames = load(sprite_frames_dict[scn])
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit()
