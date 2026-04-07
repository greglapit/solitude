extends Node2DScene

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var skip_timer : Timer = $SkipTimer

var pausing_input : bool = false

# === Custom Methods ===========================================================

func end_cutscene() -> void:
	change_scn.emit(Globals.scenes.TUTORIAL_BATTLE, false, false)
	pausing_input = true


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	if pausing_input:
		return
	if _event.is_pressed():
		if !skip_timer.is_stopped():
			end_cutscene()
		else:
			skip_timer.start()
		

# === Signals ==================================================================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"laying":
			animation_player.play("laying_cards")
		"laying_cards":
			animation_player.play("laying_cards_zoom")
			
