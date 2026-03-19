class_name Node2DScene
extends Node2D

@warning_ignore("unused_signal")
signal change_scn(target : String, prog_visible : bool)				# Sends to scenehandler
@warning_ignore("unused_signal")
signal background_load(target : String)								# Sends to scenehandler

# === Custom Methods ===========================================================

func initialize() -> void:
	pass

# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
