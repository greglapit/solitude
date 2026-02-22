class_name ConfirmationWindow
extends Control

@onready var prompt : Label = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Prompt
@onready var animation_player : AnimationPlayer = $AnimationPlayer

const conf_scn : PackedScene = preload("res://Common/UI/Confirmation Window/confirmation_window.tscn")

signal option_selected(str : String)

# === Custom Methods ===========================================================

static func prompt_user(caller : Node, question : String) -> String:
	caller.get_tree().paused = true
	var node : Control = conf_scn.instantiate()
	caller.get_tree().current_scene.add_child(node)
	node.prompt.text = question
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

# === Signals ==================================================================

func _on_yes_button_pressed() -> void:
	option_selected.emit("yes")

func _on_no_button_pressed() -> void:
	option_selected.emit("no")
	
