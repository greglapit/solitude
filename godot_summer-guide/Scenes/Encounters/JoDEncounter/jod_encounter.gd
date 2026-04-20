extends Node2DScene

@onready var player : Node2D = $Player
@onready var player_ap : AnimationPlayer = $Player/AnimationPlayer
@onready var jod_ap : AnimationPlayer = $JOD/AnimationPlayer


# === Custom Methods ===========================================================
func initialize() -> void:
	pass

	
func end_encounter() -> void:
	change_scn.emit(Globals.scenes.CAMP, false, false)

# === Built In =================================================================

func _ready() -> void:
	pass

func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_balloon_char_spoke(_char : String) -> void:
	match _char:
		"Fool":
			player_ap.play("bump")
		#"JOD":
			#jod_ap.play("bump")
		_:
			pass
