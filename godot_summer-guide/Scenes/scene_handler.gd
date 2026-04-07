extends Node

var loading_screen_scn : PackedScene = preload("res://Scenes/UI/LoadingScreen/loading_screen.tscn")
const main_menu_scn : PackedScene = preload("res://Scenes/MainMenu/main_menu.tscn")
var loading_screen : LoadingScreen
var curr_scene : Node2DScene:
	set(value):
		curr_scene_path = value.get_scene_file_path()
		curr_scene = value
var curr_scene_path : String
var save_queued : bool = false
var loading_in_background : bool = false

# DEV TOOLS
#const starting_scn : PackedScene = main_menu_scn
const starting_scn : PackedScene = preload("res://Scenes/TutorialBattle/tutorial_battle.tscn")

# === Custom Methods ===========================================================

func loadscreen_load(path : String, progress_visible : bool = true, background : bool = false) -> void:
	loading_in_background = background
	
	loading_screen = loading_screen_scn.instantiate()
	loading_screen.scene_ready.connect(_on_loading_screen_scene_ready)
	loading_screen.loading_screen_free.connect(_on_loading_screen_free)
	add_child(loading_screen)
	
	loading_screen.load(path, progress_visible, background, save_queued)
	
	save_queued = false
	
# === Built In =================================================================

func _ready() -> void:
	var init_scn : Node2DScene = starting_scn.instantiate()
	init_scn.change_scn.connect(_on_node_2d_change_scn.bind(init_scn))
	init_scn.scene_ready_for_swap.connect(_on_node_2d_scene_ready_for_swap.bind(curr_scene))
	curr_scene = init_scn
	add_child(init_scn)
	
	if init_scn.has_method("initialize"):
		init_scn.initialize()
	
	# Dialogue manager
	DialogueManager.get_current_scene = func() -> Node:
		return get_node("/root/SceneHandler").curr_scene
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and !get_parent().find_child("ConfirmationWindow"):
		if curr_scene_path in Globals.valid_save_scenes:
			var result : String = await ConfirmationWindow.prompt_user(self, "Save and quit to menu?", "Quit", "Cancel")
			if result == "Quit":
				Globals.save()
				curr_scene.change_scn.emit(Globals.scenes.MAIN_MENU, false, false)
			else:
				return
		else:
			var result : String = await ConfirmationWindow.prompt_user(self, "Cannot save during combat.\nAbandon run and exit to main menu?", "Abandon Run", "Cancel")
			if result == "Abandon Run":
				Globals.delete_save()
				curr_scene.change_scn.emit(Globals.scenes.MAIN_MENU, false, false)
				return
			else:
				return
		get_tree().root.set_input_as_handled()
		

# === Signals ==================================================================

func _on_loading_screen_scene_ready(scn : Resource) -> void:
	get_tree().paused = true
	var node_scn : Node2DScene = scn.instantiate()
	add_child(node_scn)
	curr_scene.queue_free()
	curr_scene = node_scn
	curr_scene.change_scn.connect(_on_node_2d_change_scn.bind(curr_scene))
	curr_scene.scene_ready_for_swap.connect(_on_node_2d_scene_ready_for_swap.bind(curr_scene))
	
	loading_in_background = false
	

func _on_loading_screen_free() -> void:
	get_tree().paused = false
	if curr_scene.has_method("initialize"):
		curr_scene.initialize()

func _on_node_2d_change_scn(target : Globals.scenes, prog_visible : bool, background : bool, calling_scn : Node2DScene) -> void:
	if calling_scn != curr_scene:
		push_error("Scene calling change when not the current scene.")
	
	if loading_in_background or is_instance_valid(loading_screen):
		push_error("Scene calling change when already loading already.")
	
	# Save game on transitions
	if curr_scene_path in Globals.valid_save_scenes:
		save_queued = true
		Globals.save()
	#else:
		#Globals.delete_save()
	
	var path : String = Globals.scene_paths[target]
	
	loadscreen_load(path, prog_visible, background)

		
func _on_node_2d_scene_ready_for_swap(scn : Node2DScene) -> void:
	if scn != curr_scene:
		push_error("Scene calling change when not the current scene.")
	
	loading_screen.fade_to_black()
	await loading_screen.animation_player.animation_finished
	
	loading_screen.transfer_ready = true
	
