class_name Map
extends Sprite2D

@onready var path_follow : PathFollow2D = $Path2D/PathFollow2D
@onready var rounds_label : Label = $Path2D/PathFollow2D/Control/RoundsLabel
@onready var animation_player : AnimationPlayer = $AnimationPlayer

## Used internally
const hearts_range : Array = [0,.245]
const clubs_range : Array = [.471, .671]
const spades_range : Array = [.803, 1.0]


# === Custom Methods ===========================================================

func move_player(suit : String, progress : float) -> void:
	
	var working_range : Array = get(suit + "_range")
	
	var dest : float = ((working_range[1] - working_range[0]) * progress) + working_range[0]
	var tween : Tween = create_tween()
	tween.tween_property(path_follow, "progress_ratio", dest, .8) \
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_OUT)
	
	ProgressTracker.map_last_pos = progress
	
	animation_player.play("flash_rounds")
	await get_tree().create_timer(.5).timeout		# wait to update while it is moving
	update_rounds_label()
	
	if animation_player.is_playing():
		await animation_player.animation_finished
	elif tween.is_running():
		await tween.finished

func update_rounds_label() -> void:
	rounds_label.text = str(ProgressTracker.player_location["round"]) + "/" + str(ProgressTracker.rounds_per_suit)

# === Built In =================================================================

func _ready() -> void:
	update_rounds_label()
	path_follow.progress_ratio = ProgressTracker.map_last_pos

# === Signals ==================================================================

func _on_control_mouse_entered() -> void:
	if animation_player.is_playing():
		return
	update_rounds_label()
	rounds_label.show()


func _on_control_mouse_exited() -> void:
	if animation_player.is_playing():
		return
	update_rounds_label()
	rounds_label.hide()
