class_name Node2DScene
extends Node2D

@warning_ignore("unused_signal")
signal change_scn(target : Globals.scenes, prog_visible : bool, background : bool)		# Sends to scenehandler
@warning_ignore("unused_signal")
signal scene_ready_for_swap														# When scene wants to swap to background load
var scene_id : Globals.scenes

# === Custom Methods ===========================================================

func initialize() -> void:
	pass

# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
