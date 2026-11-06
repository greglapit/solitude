extends Node2D

@onready var memory : Node2D = $JournalMemory/Memory
@onready var memory_cover : AnimatedSprite2D = $JournalMemory/MemoryCover
@onready var journal : Node2D = $JournalMemory/Journal
@onready var capacity_label : CapacityLabel = $JournalMemory/MarginContainer/CapacityLabel
@onready var explanations : CanvasLayer = $Explanations
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var pause_input : bool = false

# === Custom Methods ===========================================================



# === Built In =================================================================

func _ready() -> void:
	
	memory.armory_updated.connect(_on_memory_armory_updated)
	journal.armory_updated.connect(_on_journal_armory_updated)
	capacity_label.update()
	
	if !ProgressTracker.unlocked_memory:
		memory_cover.show()
		memory_cover.play("default")
		memory.hide()
		capacity_label.hide()
	
	if ProgressTracker.gained_first_special and !ProgressTracker.unlocked_memory:
		pause_input = true
		var balloon : Balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/UI/StudyJournal/journal_memory.dialogue"), "gained_first_special")
		balloon.layer = 5
		await balloon.tree_exited
		if animation_player.is_playing():
			await animation_player.animation_finished
		memory.show()
		animation_player.play("uncover_memory")
		animation_player.queue("explain_memory")
		await animation_player.animation_finished
		
		await get_tree().create_timer(5.0).timeout
		
		ProgressTracker.unlocked_memory = true
		pause_input = false
		
	


func _unhandled_input(event: InputEvent) -> void:
	if pause_input:
		return
	if event.is_pressed() and explanations.visible:
		pause_input = true
		animation_player.play("explain_hide")
		get_viewport().set_input_as_handled()
		await animation_player.animation_finished
		pause_input = false
		return
	#super(event)

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
