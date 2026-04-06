class_name ConfirmationWindow
extends Control

@onready var prompt : Label = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Prompt
@onready var left_button_label : Label = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/CenterContainer/Label
@onready var right_button_label : Label = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer2/CenterContainer/Label
@onready var animation_player : AnimationPlayer = $AnimationPlayer

const conf_scn : PackedScene = preload("res://Scenes/UI/Confirmation Window/confirmation_window.tscn")

signal option_selected(str : String)

# === Custom Methods ===========================================================

static func prompt_user(caller : Node, question : String, option1 : String = "Yes", option2 : String = "No") -> String:
	caller.get_tree().paused = true
	var node : ConfirmationWindow = conf_scn.instantiate()
	caller.get_tree().current_scene.add_child(node)
	node.prompt.text = question
	node.left_button_label.text = option1
	node.right_button_label.text = option2
	node.animation_player.play("spawn")
	
	var result : String = await node.option_selected
	
	node.animation_player.play("despawn")
	caller.get_tree().paused = false
	return result
	

# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	if _event.is_action_pressed("escape_menu"):
		get_viewport().set_input_as_handled()
		option_selected.emit("no")
		get_tree().root.set_input_as_handled()

# === Signals ==================================================================

func _on_left_button_pressed() -> void:
	option_selected.emit(left_button_label.text)

func _on_right_button_pressed() -> void:
	option_selected.emit(right_button_label.text)
	
