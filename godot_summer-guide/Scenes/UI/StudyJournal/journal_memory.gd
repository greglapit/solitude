extends Node2D

@onready var memory : Node2D = $CanvasLayer2/Memory
@onready var memory_cover : AnimatedSprite2D = $CanvasLayer2/MemoryCover
@onready var journal : Node2D = $CanvasLayer2/Journal
@onready var capacity_label : Label = $CanvasLayer2/MarginContainer/CapacityLabel
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var pause_input : bool = false

# === Custom Methods ===========================================================

# === Built In =================================================================

func _ready() -> void:
	if !ProgressTracker.unlocked_memory:
		memory_cover.show()
		memory_cover.play("default")
		memory.hide()
		capacity_label.hide()
	
	if ProgressTracker.gained_first_special:
		pause_input = true
		var balloon : Balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/UI/StudyJournal/journal_memory.dialogue"), "gained_first_special")
		balloon.layer = 5
		await balloon.tree_exited
		if animation_player.is_playing():
			await animation_player.animation_finished
		memory.show()
		animation_player.play("uncover_memory")
		pause_input = false
	
	memory.armory_updated.connect(_on_memory_armory_updated)
	journal.armory_updated.connect(_on_journal_armory_updated)
	capacity_label.update()
	
func _input(_event: InputEvent) -> void:
	pass
	#if pause_input:
		#get_viewport().set_input_as_handled()

# === Signals ==================================================================

func _on_memory_armory_updated() -> void:
	journal.update_buttons()
	capacity_label.update()

func _on_journal_armory_updated() -> void:
	memory.update_icons(true)
	capacity_label.update()


func _on_button_pressed() -> void:
	animation_player.play("hide")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"show":
			pass
		"hide":
			queue_free()
