extends Node2DScene

@onready var ui_animation_player : AnimationPlayer = $UI/UIAnimationPlayer
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var skip_timer : Timer = $SkipTimer

var hold_time : float
var pausing_input : bool = false

# === Custom Methods ===========================================================

func end_cutscene() -> void:
	change_scn.emit(Globals.scenes.TUTORIAL_BATTLE, false, false)


# === Built In =================================================================

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if !pausing_input and Input.is_anything_pressed():
		
		if Input.is_physical_key_pressed(Key.KEY_X):
			hold_time += delta
			if hold_time >= 3.0:
				end_cutscene()
				pausing_input = true
		
		# Refresh showing skip instruction if anything is pressed
		if ui_animation_player.is_playing():
			ui_animation_player.seek(.1)
		else:
			ui_animation_player.play("skip_instruction_show")


# === Signals ==================================================================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"laying":
			animation_player.play("laying_cards")
		"laying_cards":
			animation_player.play("laying_cards_zoom")
			
