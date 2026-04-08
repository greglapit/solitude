class_name TutorialBattle
extends Battle

@onready var tutorial_ap : AnimationPlayer = $AnimationPlayer

var tutorial_cards : Array[Dictionary] = [
	{
		"rank" = 2,
	},
	{
		"rank" = 2,
	},
	{
		"rank" = 2,
	}
]

var tutorial_enemies : Array[Dictionary] = [
	
	# First Set of Enemies
	{
		"rank" = 3,
		"true_rank" = 3
	},
	{
		"rank" = 3,
		"true_rank" = 3
	},
	{
		"rank" = 3,
		"true_rank" = 3
	}
	
	# Second Set of Enemies
]

#var tutorial_finished : bool = false

# === Custom Methods ===========================================================

func wait(sec : float) -> Signal:
	return await get_tree().create_timer(sec).timeout
	
func initialize() -> void:
	var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), "start")
	await balloon.char_spoke
	balloon.dialogue_label.started_typing.connect(_on_started_typing)
	balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
	
	await balloon.tree_exited
	pause_input = false

func end_battle() -> void:
	player.play("base_dazed")
	await get_tree().create_timer(3.0).timeout
	change_scn.emit(Globals.scenes.CAMP, false, false)

func spawn_tutorial_card(amt : int = 3) -> void:
	for i : int in range(amt):
		spawn_card(tutorial_cards[0])
		tutorial_cards.remove_at(0)
	align_mini_cards(true)

func spawn_tutorial_enemy(amt : int = 3) -> void:
	for i : int in range(amt):
		spawn_enemy(1, tutorial_enemies[0])
		tutorial_enemies.remove_at(0)
		await get_tree().create_timer(0.2).timeout

# No tatters from first fight
func update_tatters() -> void:
	pass

func play

# === Built In =================================================================

func _ready() -> void:
	super()
	#weapons_display.hide()
	weapons_display.joker.hide()
	weapons_display.draw_button.hide()
	attack_buttons_ui.hide()
	turn_clock.hide()
	health_bar.hide()
	tatter_count.hide()
	hands_label.hide()
	
	player.play("tutorial_laying")
	
func _unhandled_input(_event: InputEvent) -> void:
	return
	#if !tutorial_finished:
		#return
	#super(event)

# === Signals ==================================================================


func _on_started_typing() -> void:
	weapons_display.play("joker_talking")
	
func _on_finished_typing() -> void:
	weapons_display.play("joker_idle")
