extends Node

@onready var loading_screen : LoadingScreen

var loading_screen_scn : PackedScene = preload("res://Scenes/loading_screen.tscn")
const main_menu_scn : PackedScene = preload("res://Scenes/MainMenu/main_menu.tscn")
var curr_scene : Node2DScene:
	set(value):
		curr_scene_path = value.get_scene_file_path()
		curr_scene = value
var curr_scene_path : String
var save_queued : bool = false

# DEV TOOLS
const starting_scn : PackedScene = main_menu_scn
#const starting_scn : PackedScene = preload("res://Scenes/EnteringBattle/entering_battle.tscn")

# === Custom Methods ===========================================================

func loadscreen_load(path : String, progress_visible : bool = true) -> void:
	loading_screen = loading_screen_scn.instantiate()
	loading_screen.scene_ready.connect(_on_loading_screen_scene_ready)
	loading_screen.loading_screen_free.connect(_on_loading_screen_free)
	add_child(loading_screen)
	
	loading_screen.load(path, progress_visible, save_queued)
	save_queued = false
	
# === Built In =================================================================

func _ready() -> void:
	var init_scn : Node2DScene = starting_scn.instantiate()
	init_scn.change_scn.connect(_on_node_2d_change_scn.bind(init_scn))
	init_scn.background_load.connect(_on_node_2d_background_load.bind(init_scn))
	curr_scene = init_scn
	add_child(init_scn)
	
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_loading_screen_scene_ready(scn : Resource) -> void:
	var node_scn : Node2DScene = scn.instantiate()
	add_child(node_scn)
	curr_scene.queue_free()
	curr_scene = node_scn
	curr_scene.change_scn.connect(_on_node_2d_change_scn.bind(curr_scene))
	curr_scene.background_load.connect(_on_node_2d_background_load.bind(curr_scene))

func _on_loading_screen_free() -> void:
	if curr_scene.has_method("initialize"):
		curr_scene.initialize()

func _on_node_2d_change_scn(path : String, prog_visible : bool, scn : Node2DScene) -> void:
	if path == "res://Scenes/MainMenu/main_menu.tscn":
		if scn.get_scene_file_path() in Globals.valid_save_scenes:
			save_queued = true
		else:
			Globals.delete_save()
			pass
	
	if scn == curr_scene:
		loadscreen_load(path, prog_visible)
	else:
		push_error("Scene calling change when not the current scene.")

func _on_node_2d_background_load(path : String, scn : Node2DScene) -> void:
	#if scn == curr_scene:
		#loadscreen_load(path, true)
	#else:
		#push_error("Scene calling change when not the current scene.")
