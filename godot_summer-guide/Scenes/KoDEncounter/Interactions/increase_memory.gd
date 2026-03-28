extends Node

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var capacity_label : Label = $CanvasLayer/MarginContainer/CapacityLabel

# Set to amount memory should increase by

## Used internally
var event_completed : bool = false



# === Custom Methods ===========================================================

func increase_memory_capacity() -> void:
	var core_stack : ItemStack = Globals.inventory["core"]
	var cores_being_used : int = core_stack.count
	Globals.memory_capacity += cores_being_used
	capacity_label.update()
	Globals.add_item("core", -core_stack.count)
	await animation_player.animation_finished
	

# === Built In =================================================================

func _ready() -> void:
	capacity_label.display_current_stress = false
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
