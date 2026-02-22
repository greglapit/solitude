extends Node2D

@onready var animation_player : AnimationPlayer = $Sprite2D/AnimationPlayer

var curr_anim : turn
var locked : bool

enum turn {UP, DOWN, HALF,CONFUSED, PROWLER_BUSH}

func show_turn(_turn : turn) -> void:
	if locked or _turn == curr_anim:
		return
	
	match _turn:
		turn.PROWLER_BUSH:
			animation_player.play("prowler_bush")
		turn.CONFUSED:
			animation_player.play("confused")
	
	# So correct transition plays
	if curr_anim != turn.UP or _turn != turn.HALF or _turn != turn.DOWN:
		curr_anim = turn.HALF
	match _turn:
		turn.UP:
			animation_player.play(turn.keys()[curr_anim].to_lower() + "_to_up")
		turn.DOWN:
			animation_player.play(turn.keys()[curr_anim].to_lower() + "_to_down")
		turn.HALF:
			if curr_anim == turn.HALF:
				animation_player.play("RESET")
			else:
				animation_player.play(turn.keys()[curr_anim].to_lower() + "_to_half")
	curr_anim = _turn

func _ready() -> void:
	curr_anim = turn.HALF
	animation_player.play("RESET")
