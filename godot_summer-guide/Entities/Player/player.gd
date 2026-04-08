class_name Player
extends Node2D

# Status Effects
var dazed : bool = false:
	set(value):
		dazed = value
		status_logic_update()

var attack_disabled : bool = false

# Effect Logic

@onready var animation_player : AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var effects_animation_player : AnimationPlayer = $Effects/AnimationPlayer

@warning_ignore("unused_signal")
signal attack_impact				## Time in animation when animation hits. Emitted by animation player
@warning_ignore("unused_signal")
signal special_impact				## Time in animation when animation hits. Emitted by animation player
@warning_ignore("unused_signal")
signal weap_effect_start			## Time in animation when weapon effect should start. Sent to weapon in battle scene
signal anim_finished(anim : String)

# === Custom Methods ===========================================================

func play(anim : StringName) -> void:
	animation_player.play(anim)
	await animation_player.animation_finished
	
func effect(anim : StringName) -> void:
	effects_animation_player.play(anim)
	return
	
func queue(anim : StringName) -> void:
	animation_player.queue(anim)
	return

func status_logic_update() -> void:
	if dazed:
		attack_disabled = true
	else:
		attack_disabled = false

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
