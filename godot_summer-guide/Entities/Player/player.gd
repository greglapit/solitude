extends Node2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

@warning_ignore("unused_signal")
signal attack_impact				## Time in animation when animation hits. Emitted by animation player
@warning_ignore("unused_signal")
signal special_impact				## Time in animation when animation hits. Emitted by animation player
@warning_ignore("unused_signal")
signal weap_effect_start			## Time in animation when weapon effect should start. Sent to weapon in battle scene
signal anim_finished(anim : String)

# === Custom Methods ===========================================================

func play(anim : StringName) -> void:
	animation_player.stop()
	animation_player.play(anim)
	#animation_player.seek(0.0, true)
	return
	
func queue(anim : StringName) -> void:
	animation_player.queue(anim)
	return

# === Built In =================================================================

func _ready() -> void:
	animation_player.queue("base_idle")
	
func _input(_event: InputEvent) -> void:
	pass

func _process(_delta: float) -> void:
	pass

# === Signals ==================================================================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	anim_finished.emit(anim_name)
	 #Loops idle animations
	if anim_name.contains("idle"):
		animation_player.play(anim_name)
	#elif anim_name.contains("attack"):
		#animation_player.play(anim_name.replace("attack", "idle"))
	#elif anim_name.contains("defend"):
		#animation_player.play(anim_name.replace("defend", "idle"))
