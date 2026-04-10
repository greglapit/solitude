class_name TutorialBattle
extends Battle

var cards_left_on_ground : int = 4
var hinted_equip_card : bool = false
var equipped_first_card : bool = false
var equipped_second_card : bool = false
var equipped_fourth_card : bool = false
var hinted_grab_new_card : bool = false
var explained_initiative : bool = false
var explained_chain : bool = false
var explained_cut_socket : bool = false
enum explains {
	INITIATIVE,
	CHAIN,
	CUT_SOCKET
}
var grabbed_last_card : bool = false
var enemy_freed_counter : int = 0

var force_grab_card : bool = false

@onready var explanations : CanvasLayer = $Explanations
@onready var cards_on_ground : Sprite2D = $CardsOnGround
@onready var tutorial_ap : AnimationPlayer = $AnimationPlayer

var tutorial_cards : Array[Dictionary] = [
	{
		"rank" = 2,
	},
	{
		"rank" = 1,
	},
	{
		"rank" = 2,
	},
	{
		"rank" = 3,
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
	},
	
	# Second Set of Enemies
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
]



# === Custom Methods ===========================================================

func wait(sec : float) -> Signal:
	return await get_tree().create_timer(sec).timeout
	
func initialize() -> void:
	var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), "start")
	await balloon.char_spoke
	balloon.dialogue_label.started_typing.connect(_on_started_typing)
	balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
	
	await balloon.tree_exited
	
	tutorial_ap.play("draw_button_show")
	await tutorial_ap.animation_finished
	weapons_display.play("draw_highlight")
	pause_input = false

func end_battle() -> void:
	player.play("base_dazed")
	await get_tree().create_timer(3.0).timeout
	change_scn.emit(Globals.scenes.CAMP, false, false)


func equip_mini_card(mini_card : MiniCard = null, player_update : bool = true) -> void:
	if force_grab_card:
		weapons_display.play("draw_highlight")
		return
	
	super(mini_card, player_update)
	
	
	if mini_equipped and !grabbed_last_card:
		match cards_left_on_ground:
			3: # Picked up the first DAGGER
				if mini_equipped.rank != 2 or equipped_first_card:
					return
				var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), "equip_first_card")
				await balloon.char_spoke
				balloon.dialogue_label.started_typing.connect(_on_started_typing)
				balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
				await balloon.tree_exited
				equipped_first_card = true
				
				# Show when equipping for first time
				chain_button.hide()
				await tutorial_ap.animation_finished
				
				
			2: # Picked second ACE
				if mini_equipped.rank != 1 or equipped_second_card:
					return
				var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), "equip_second_card")
				await balloon.char_spoke
				balloon.dialogue_label.started_typing.connect(_on_started_typing)
				balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
				await balloon.tree_exited
				equipped_second_card = true
			1:
				pass
			0: # Picked third SPEAR
				if mini_equipped.rank != 3 or equipped_fourth_card:
					return
				var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), "equip_fourth_card")
				await balloon.char_spoke
				balloon.dialogue_label.started_typing.connect(_on_started_typing)
				balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
				await balloon.tree_exited
				equipped_fourth_card = true
	
	

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
		grabbed_last_card = true

func spawn_tutorial_enemy(amt : int = 3) -> void:
	for i : int in range(amt):
		spawn_enemy(1, tutorial_enemies[0])
		tutorial_enemies.remove_at(0)
		await get_tree().create_timer(0.2).timeout

# No tatters from first fight
func update_tatters() -> void:
	pass


func explain(scn : explains) -> void:
	if explanations.visible:
		return
	pause_input = true
	match scn:
		explains.INITIATIVE:
			tutorial_ap.play("explain_initiative")
			await tutorial_ap.animation_finished
			explained_initiative = true
		explains.CHAIN:
			tutorial_ap.play("explain_chain")
			await tutorial_ap.animation_finished
			tutorial_ap.play("chain_button_show")
			await tutorial_ap.animation_finished
			explained_chain = true
		explains.CUT_SOCKET:
			tutorial_ap.play("explain_cut_socket")
			await tutorial_ap.animation_finished
			explained_cut_socket = true
	
	await get_tree().create_timer(5.0).timeout
	pause_input = false
	
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

func _unhandled_input(event: InputEvent) -> void:
	if pause_input:
		return
	if event.is_pressed() and explanations.visible:
		tutorial_ap.play("explain_hide")
		get_viewport().set_input_as_handled()
		await tutorial_ap.animation_finished
		return
	#super(event)
	

# === Signals ==================================================================


func _on_started_typing() -> void:
	weapons_display.play("joker_talking")
	
func _on_finished_typing() -> void:
	weapons_display.play("joker_idle")


func _on_draw_button_pressed() -> void:
	if grabbed_last_card:
		super()
		return
	
	if pause_input:
		return
		
	force_grab_card = false
	pause_input = true
	actions -= 1
	weapons_display.buttons_enabled(false)
	weapons_display.play("RESET")
	player.play("tutorial_grab_cards")
	await player.anim_finished
	spawn_tutorial_card(1)
	
	# Grabbed second card
	if cards_left_on_ground == 1:
		await get_tree().create_timer(.5).timeout
		explain(explains.CHAIN)
	
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
		
		force_grab_card = true
		hinted_grab_new_card = true 

func _on_enemy_freed(_enemy : Enemy) -> void:
	super(_enemy)
	enemy_freed_counter += 1


func _on_explanations_gui_input(event: InputEvent) -> void:
	_unhandled_input(event)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"explain_hide":
			if turn_clock.visible == false:
				tutorial_ap.play("attack_buttons_show")
				await tutorial_ap.animation_finished
