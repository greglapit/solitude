class_name Weapon
extends Node2D

var rank : int = -1
var file_name : String = "PlaceHolder"
var display_name : String = "PlaceHolder"
@onready var animation_player : AnimationPlayer = $WeaponEffects

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
