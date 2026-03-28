class_name Map
extends Sprite2D

@onready var path_follow : PathFollow2D = $Path2D/PathFollow2D

## Used internally
const hearts_range : Array = [0,.245]
const clubs_range : Array = [.471, .671]
const spades_range : Array = [.803, 1.0]

func move_player(suit : String, progress : float) -> void:
	var working_range : Array = get(suit + "_range")
	
	var dest : float = ((working_range[1] - working_range[0]) * progress) + working_range[0]
	var tween : Tween = create_tween()
	tween.tween_property(path_follow, "progress_ratio", dest, .8) \
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
func _ready() -> void:
	path_follow.progress_ratio = ProgressTracker.map_last_pos
