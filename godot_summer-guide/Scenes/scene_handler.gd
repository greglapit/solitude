extends Node

@onready var loading_screen : LoadingScreen = $LoadingScreen

var curr_scene : Node
const main_menu_scn : PackedScene = preload("res://Scenes/MainMenu/main_menu.tscn")

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	var main_menu : Node2D = main_menu_scn.instantiate()
	main_menu.play_button_pressed.connect(_on_main_menu_play_button_pressed)
	curr_scene = main_menu
	add_child(main_menu)
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_loading_screen_scene_ready(path: String) -> void:
	var scn : Resource = ResourceLoader.load_threaded_get(path)
	var node_scn : Node = scn.instantiate()
	add_child(node_scn)
	curr_scene.queue_free()
	curr_scene = node_scn

func _on_main_menu_play_button_pressed() -> void:
	loading_screen.load("res://Scenes/Battle/battle.tscn")
