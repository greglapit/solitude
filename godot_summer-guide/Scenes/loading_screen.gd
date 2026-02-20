extends Node2D
class_name LoadingScreen


var path: String
var progress_value : float = 0.0
signal scene_loaded(path: String)


func load(path_to_load : String) -> void:
	path = path_to_load
	ResourceLoader.load_threaded_request(path)


func _process(delta: float) -> void:
	if not path:
		return

	var progress : Array = []
	var status : int  = ResourceLoader.load_threaded_get_status(path, progress)

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		progress_value = progress[0] * 100
		progress_bar.value = move_toward(progress_bar.value, progress_value, delta * 20)

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		# zip the progress bar to 100% so we don't get weird visuals
		progress_bar.value = move_toward(progress_bar.value, 100.0, delta * 150)

		# "done" loading :)
		if progress_bar.value >= 99:
			scene_loaded.emit(path)
