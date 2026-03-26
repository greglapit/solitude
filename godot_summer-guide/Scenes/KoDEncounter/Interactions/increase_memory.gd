extends Node

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var capacity_label : Label = $CanvasLayer/MarginContainer/CapacityLabel

## Set when play animation has finished and ready to hide
var event_completed : bool = false

# === Custom Methods ===========================================================

func increase_memory_capacity() -> void:
	Globals.memory_capacity += 1
	capacity_label.update()

# === Built In =================================================================

func _ready() -> void:
	capacity_label.update()
	animation_player.play("show")
	
func _input(_event: InputEvent) -> void:
	if _event.is_pressed():
		if event_completed:
			animation_player.play("hide")
		get_viewport().set_input_as_handled()

	

# === Signals ==================================================================


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"show":
			event_completed = true
		"hide":
			queue_free()
