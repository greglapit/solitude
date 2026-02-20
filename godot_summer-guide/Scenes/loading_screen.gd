extends Node2D
class_name LoadingScreen

@onready var number_label : Label = $CanvasLayer/Control/MarginContainer/HBoxContainer/Number
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var path: String
var progress_value : float = 0.0		# Progress of loading scene
signal scene_ready(path: String)


func load(path_to_load : String) -> void:
	path = path_to_load
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	ResourceLoader.load_threaded_request(path)

func _ready() -> void:
	number_label.text = str(progress_value)

func _process(delta: float) -> void:
	if not path:
		return
		
	var progress : Array = []
	var status : int  = ResourceLoader.load_threaded_get_status(path, progress)
	var current_value : float = float(number_label.text)
	
	progress_value = progress[0] * 100
	number_label.text = "%.2f" % move_toward(current_value, progress_value, delta * 150)
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		if current_value >= 99:
			path = ""
			animation_player.play("fade_out")
			await animation_player.animation_finished
			scene_ready.emit(path)
