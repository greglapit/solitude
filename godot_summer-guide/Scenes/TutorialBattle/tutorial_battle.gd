class_name TutorialBattle
extends Battle

var cards_left_on_ground : int = 4
var hinted_equip_card : bool = false
var equipped_first_card : bool = false
var hinted_grab_new_card : bool = false
var enemy_freed_counter : int = 0

@onready var cards_on_ground : Sprite2D = $CardsOnGround
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
		"rank" = 2,
		"true_rank" = 2
	},
	{
		"rank" = 5,
		"true_rank" = 5
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


func equip_mini_card(mini_card : MiniCard = null, player_update : bool = true) -> void:
	super(mini_card, player_update)
	
	if cards_left_on_ground <= 0:
		weapons_display.buttons_enabled(false, false)
	
	if !equipped_first_card and mini_equipped:
		var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), "equip_first_card")
		await balloon.char_spoke
		balloon.dialogue_label.started_typing.connect(_on_started_typing)
		balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
		equipped_first_card = true
		
		await balloon.tree_exited
		# Show when equipping for first time
		chain_button.hide()
		tutorial_ap.play("attack_buttons_show")
	

func spawn_tutorial_card(amt : int = 1) -> void:
	if cards_left_on_ground == 0:
		return
		
	for i : int in range(amt):
		spawn_card(tutorial_cards[0])
		tutorial_cards.remove_at(0)
	align_mini_cards(true)
	cards_left_on_ground -= 1
	cards_on_ground.frame = min(cards_on_ground.frame + 1, 4)
	
	if cards_left_on_ground == 0:
		weapons_display.draw_button.hide()

func spawn_tutorial_enemy(amt : int = 3) -> void:
	for i : int in range(amt):
		spawn_enemy(1, tutorial_enemies[0])
		tutorial_enemies.remove_at(0)
		await get_tree().create_timer(0.2).timeout

# No tatters from first fight
func update_tatters() -> void:
	pass



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
	weapons_display.draw_button_label.text = "Grab Card"
	
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


func _on_draw_button_pressed() -> void:
	if pause_input:
		return
	
	pause_input = true
	actions -= 1
	weapons_display.buttons_enabled(false)
	player.play("tutorial_grab_cards")
	await player.anim_finished
	spawn_tutorial_card(1)
	
	player.play("base_idle")
	
	if !hinted_equip_card:
		var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), "hint_equip_card")
		await balloon.char_spoke
		balloon.dialogue_label.started_typing.connect(_on_started_typing)
		balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
		hinted_equip_card = true
		
		await balloon.tree_exited

	pause_input = false

func _on_weapon_combat_fin(_weapon : Weapon) -> void:
	super(_weapon)
	if equipped_first_card and !hinted_grab_new_card:
		var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), "hint_grab_new_card")
		await balloon.char_spoke
		balloon.dialogue_label.started_typing.connect(_on_started_typing)
		balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
		
		hinted_grab_new_card = true 

func _on_enemy_freed(_enemy : Enemy) -> void:
	super(_enemy)
	enemy_freed_counter += 1
