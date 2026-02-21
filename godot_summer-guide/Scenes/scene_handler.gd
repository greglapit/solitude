extends Node

@onready var loading_screen : LoadingScreen

var loading_screen_scn : PackedScene = preload("res://Scenes/loading_screen.tscn")
var curr_scene : Node
const main_menu_scn : PackedScene = preload("res://Scenes/MainMenu/main_menu.tscn")

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	var main_menu : Node2D = main_menu_scn.instantiate()
	main_menu.new_game_button_pressed.connect(_on_main_menu_new_game_button_pressed)
	curr_scene = main_menu
	add_child(main_menu)
	
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_loading_screen_scene_ready(scn : Resource) -> void:
	var node_scn : Node = scn.instantiate()
	add_child(node_scn)
	curr_scene.queue_free()
	curr_scene = node_scn

func _on_loading_screen_free() -> void:
	curr_scene.initialize()

func _on_main_menu_new_game_button_pressed() -> void:
	curr_scene.process_mode = Node.PROCESS_MODE_DISABLED
	loading_screen = loading_screen_scn.instantiate()
	loading_screen.scene_ready.connect(_on_loading_screen_scene_ready)
	loading_screen.loading_screen_free.connect(_on_loading_screen_free)
	add_child(loading_screen)
	loading_screen.load("res://Scenes/Battle/battle.tscn")
