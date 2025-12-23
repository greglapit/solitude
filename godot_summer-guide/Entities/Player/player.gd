extends Node2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer
var anims = ['base_idle', 'base_defend', '1_idle', '1_defend', '1_attack', '2_idle', '2_defend', '2_attack', '3_idle', '3_defend', '3_attack', '4_idle', '4_defend', '4_attack', '5_idle', '5_defend', '5_attack', '6_idle', '6_defend', '6_attack', '7_idle', '7_defend', '7_attack', '8_idle', '8_defend', '8_attack', '9_idle', '9_defend', '9_attack', '10_idle', '10_defend', '10_attack']
var count = 0

# === Custom Methods ===========================================================
func play_anim(anim):
	animation_player.play(anim)
	return

# === Built In =================================================================

func _ready() -> void:
	for anim in anims:
		animation_player.queue(anim)
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
