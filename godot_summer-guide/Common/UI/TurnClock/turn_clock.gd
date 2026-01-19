extends Sprite2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var curr_anim : turn

enum turn {UP, DOWN, HALF,CONFUSED}

func show_turn(_turn : turn) -> void:
	if _turn == curr_anim:
		return
	match _turn:
		turn.CONFUSED:
			animation_player.play("confused")
		turn.UP:
			animation_player.play(turn.keys()[curr_anim].to_lower() + "_to_up")
		turn.DOWN:
			animation_player.play(turn.keys()[curr_anim].to_lower() + "_to_down")
		turn.HALF:
			animation_player.play(turn.keys()[curr_anim].to_lower() + "_to_half")
	curr_anim = _turn

func _ready() -> void:
	curr_anim = turn.HALF
	animation_player.play("RESET")
	show_turn(turn.UP)
