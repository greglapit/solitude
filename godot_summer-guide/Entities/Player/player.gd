extends Node2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer
var anims : Array[StringName] = ['base_idle', 'base_defend', \
'1_base_idle', '1_base_defend', '1_base_attack', \
'2_base_idle', '2_base_defend', '2_base_attack', \
'3_base_idle', '3_base_defend', '3_base_attack', \
'4_base_idle', '4_base_defend', '4_base_attack', \
'5_base_idle', '5_base_defend', '5_base_attack', \
'6_base_idle', '6_base_defend', '6_base_attack', \
'7_base_idle', '7_base_defend', '7_base_attack', \
'8_base_idle', '8_base_defend', '8_base_attack', \
'9_base_idle', '9_base_defend', '9_base_attack', \
'10_base_idle', '10_base_defend', '10_base_attack']
var count : int = 0

# === Custom Methods ===========================================================
func play(anim : StringName) -> void:
	if animation_player.current_animation.contains("_attack"):
		animation_player.queue(anim)
	else:
		animation_player.play(anim)
	return
	
func queue(anim : StringName) -> void:
	animation_player.queue(anim)
	return

# === Built In =================================================================

func _ready() -> void:
	animation_player.queue("base_idle")
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	# Loops idle animations
	if anim_name.contains("idle"):
		animation_player.play(anim_name)
	elif anim_name.contains("attack"):
		animation_player.play(anim_name.replace("attack", "idle"))
	elif anim_name.contains("defend"):
		animation_player.play(anim_name.replace("defend", "idle"))
