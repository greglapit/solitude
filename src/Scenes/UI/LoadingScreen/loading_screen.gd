class_name LoadingScreen
extends Node2D

@onready var progress_label : HBoxContainer = $CanvasLayer/Control/MarginContainer/HBoxContainer
@onready var number_label : Label = $CanvasLayer/Control/MarginContainer/HBoxContainer/Number
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var path : String
var progress_value : float = 0.0		# Progress of loading scene
var transfer_ready : bool = false
signal scene_ready(scn : Resource)
signal loading_screen_free

func load(path_to_load : String, progress_visible : bool = false, background : bool = false, saving : bool = false) -> void:
	
	progress_label.visible = progress_visible
	transfer_ready = !background
	
	path = path_to_load
	if !background:
		transfer_ready = true					# Will immediately transfer when finished loading
		animation_player.play("fade_to_black")
		await animation_player.animation_finished
	
	ResourceLoader.load_threaded_request(path)
	
	if saving:
		await Globals.save()
		

func fade_to_black() -> void:
	animation_player.play("fade_to_black")
	

func fade_to_scn() -> void:
	animation_player.play("fade_to_scn")
	await animation_player.animation_finished
	loading_screen_free.emit()
	queue_free()
	

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
	if progress_label.visible == true:
		# Slows down progress bar
		number_label.text = "%.0f" % move_toward(current_value, progress_value, _delta * 150)
	else:
		number_label.text = "%.0f" % progress_value
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		if current_value >= 99 and transfer_ready:
			scene_ready.emit(ResourceLoader.load_threaded_get(path))
			path = ""
			fade_to_scn()
			
