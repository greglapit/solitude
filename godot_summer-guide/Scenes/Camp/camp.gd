extends Node2DScene

@onready var background : AnimatedSprite2D = $Background
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var health_bar : HealthBar = $CanvasLayer/HealthBar
@onready var plus_heal_label : Label = $CanvasLayer/PlusHealLabel
@onready var rest_button : TextureButton = $CanvasLayer/MarginContainer/RestButton
@onready var journal_button : TextureButton = $CanvasLayer/MarginContainer2/JournalButton

const journal_memory_scn : PackedScene = preload("res://Scenes/UI/StudyJournal/journal_memory.tscn")

const campfire_heal_amt : int = 3

var force_check_journal : bool = false
var pause_input : bool = false

# === Custom Methods ===========================================================
func initialize() -> void:
	pause_input = true
	if !ProgressTracker.unlocked_journal:
		var balloon : Balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/Camp/camp.dialogue"), "start")
		await balloon.tree_exited
		
		animation_player.play("journal_button_show")
		ProgressTracker.unlocked_journal = true
		force_check_journal = true
	elif ProgressTracker.gained_first_special and !ProgressTracker.unlocked_memory:
		force_check_journal = true
	pause_input = false


# === Built In =================================================================

func _init() -> void:
	scene_id = Globals.scenes.CAMP

func _ready() -> void:
	if !ProgressTracker.unlocked_journal:
		journal_button.hide()
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================


func _on_journal_button_pressed() -> void:
	if pause_input:
		return
	force_check_journal = false
	
	var journal_memory_node : Node2D = journal_memory_scn.instantiate()
	add_child(journal_memory_node)
	
	pause_input = true
	journal_button.disabled = true
	background.pause()
	await journal_memory_node.tree_exited
	
	pause_input = false
	journal_button.disabled = false
	background.play()

func _on_rest_button_pressed() -> void:
	if pause_input:
		return
		
	if force_check_journal:
		var balloon : Balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/Camp/camp.dialogue"), "unlocked_journal")
		await balloon.tree_exited
		return
	
	pause_input = true
	rest_button.disabled = true
	journal_button.disabled = true
	plus_heal_label.text = "+" + str(campfire_heal_amt)
	animation_player.play("plus_health")
	
	Globals.hp += campfire_heal_amt
	health_bar.display_hp(Globals.hp)
	await animation_player.animation_finished
	
	
	change_scn.emit(Globals.scenes.NIGHTTIME, false, false)
