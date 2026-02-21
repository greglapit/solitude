extends Node2D
class_name LoadingScreen

@onready var number_label : Label = $CanvasLayer/Control/MarginContainer/HBoxContainer/Number
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var path : String
var progress_value : float = 0.0		# Progress of loading scene
signal scene_ready(scn : Resource)
signal loading_screen_free


func load(path_to_load : String) -> void:
	path = path_to_load
	
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	ResourceLoader.load_threaded_request(path)
	
	get_tree().paused = true
	
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	number_label.text = str(progress_value)

func _process(_delta: float) -> void:
	if not path:
		return
		
	var progress : Array = []
	var status : int  = ResourceLoader.load_threaded_get_status(path, progress)
	var current_value : float = float(number_label.text)
	
	progress_value = progress[0] * 100
	#number_label.text = "%.0f" % progress_value
	number_label.text = "%.0f" % move_toward(current_value, progress_value, _delta * 150)
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		if current_value >= 99:
			scene_ready.emit(ResourceLoader.load_threaded_get(path))
			path = ""
			animation_player.play("fade_to_scn")
			await animation_player.animation_finished
			get_tree().paused = false
			loading_screen_free.emit()
			queue_free()
