extends Camera2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var center_pos : Vector2 = Vector2(320,180)
var shake_strength: float = 0.0
var shake_fade: float = 10.0

# === Custom Methods ===========================================================

func reset_camera() -> Signal:
	var tween : Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "rotation", 0, 0.1) \
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset", Vector2(320,180), 0.1) \
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_OUT)
	return tween.finished

func play(anim : String) -> void:
	await reset_camera()
	animation_player.play(anim)

# === Built In =================================================================

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if shake_strength > 0:
		var weight : float = 1 - exp(-shake_fade * delta)
		shake_strength = lerp(shake_strength, 0.0, weight)
		offset = center_pos + Vector2( 
			randf_range(-shake_strength, shake_strength), 
			randf_range(-shake_strength, shake_strength))
	else:
		offset = Vector2.ZERO

# === Signals ==================================================================
