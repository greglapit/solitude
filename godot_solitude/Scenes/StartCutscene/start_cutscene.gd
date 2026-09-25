extends Node2DScene

@onready var ui_animation_player : AnimationPlayer = $UI/UIAnimationPlayer
@onready var black_screen : ColorRect = $UI/BlackScreen
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var skip_timer : Timer = $SkipTimer

var hold_time : float
var pausing_input : bool = false

# === Custom Methods ===========================================================

func end_cutscene() -> void:
	change_scn.emit(Globals.scenes.TUTORIAL_BATTLE, false, false)
	process_mode = Node.PROCESS_MODE_DISABLED


# === Built In =================================================================

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if !pausing_input and Input.is_anything_pressed():
		
		if Input.is_physical_key_pressed(Key.KEY_X):
			hold_time += delta
			if hold_time >= 2.0:
				end_cutscene()
				pausing_input = true
				
			elif hold_time >= 0.5:
				black_screen.modulate = lerp(black_screen.modulate, Color(1.0, 1.0, 1.0, 1.0), 2.0 * delta)
		
		# Refresh showing skip instruction if anything is pressed
		if ui_animation_player.is_playing():
			ui_animation_player.seek(.1)
		else:
			ui_animation_player.play("skip_instruction_show")
	else:
		hold_time = 0
		black_screen.modulate = lerp(black_screen.modulate, Color(1.0, 1.0, 1.0, 0.0), 5.0 * delta)


# === Signals ==================================================================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"laying":
			animation_player.play("laying_cards")
		"laying_cards":
			animation_player.play("laying_cards_zoom")
			
