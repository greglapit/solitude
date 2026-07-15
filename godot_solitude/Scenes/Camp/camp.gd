extends Node2DScene

@onready var background : AnimatedSprite2D = $Background
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var health_bar : HealthBar = $CanvasLayer/HealthBar
@onready var plus_heal_label : Label = $CanvasLayer/PlusHealLabel
@onready var rest_button : TextureButton = $CanvasLayer/MarginContainer/RestButton
@onready var journal_button : TextureButton = $CanvasLayer/MarginContainer2/JournalButton

const journal_memory_scn : PackedScene = preload("res://Scenes/UI/StudyJournal/journal_memory.tscn")

const campfire_heal_amt : int = 3

var pause_input : bool = false

# === Custom Methods ===========================================================
func initialize() -> void:
	pause_input = true
	if !ProgressTracker.unlocked_journal:
		var balloon : Balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/Camp/camp.dialogue"), "start")
		await balloon.tree_exited
		
		# Gift ranks 1-3
		var gift_rank_scn : GiftRank = load("res://Scenes/Encounters/QoDEncounter/Interactions/gift_rank.tscn").instantiate()
		gift_rank_scn.ranks_to_unlock = range(1,4)
		add_child(gift_rank_scn)
		await gift_rank_scn.tree_exited
		
		animation_player.queue("journal_button_show")
		ProgressTracker.unlocked_journal = true
		hide_rest(true)
	elif ProgressTracker.gained_first_special and !ProgressTracker.unlocked_memory:
		show_journal_button(true)
		hide_rest(true)
	else:
		show_journal_button(true)
		hide_rest(false)
	pause_input = false

func hide_rest(status : bool) -> void:
	if status:
		animation_player.queue("rest_button_hide")
	else:
		animation_player.queue("rest_button_show")

func show_journal_button(status : bool) -> void:
	if status:
		while animation_player.current_animation != "journal_button_show":
			animation_player.queue("journal_button_show")
			await animation_player.animation_finished
		animation_player.seek(animation_player.current_animation.length())
	else:
		journal_button.hide()

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
	hide_rest(false)
	
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
		
	#if hide_rest:
		#var balloon : Balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/Camp/camp.dialogue"), "unlocked_journal")
		#await balloon.tree_exited
		#return
	
	pause_input = true
	rest_button.disabled = true
	journal_button.disabled = true
	plus_heal_label.text = "+" + str(campfire_heal_amt)
	animation_player.queue("plus_health")
	
	Globals.hp += campfire_heal_amt
	health_bar.display_hp(Globals.hp)
	await animation_player.animation_finished
	
	
	change_scn.emit(Globals.scenes.NIGHTTIME, false, false)
