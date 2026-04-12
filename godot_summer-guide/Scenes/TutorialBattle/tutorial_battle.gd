class_name TutorialBattle
extends Battle

var cards_left_on_ground : int = 4
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

var force_grab_card : bool = false		# Force player to grab card
var force_equip_rank : int = 0 			# Card rank to be forced to equip
var force_chain_attack : bool = false	# Force player to pick chain

var highlighted_card : MiniCard

@onready var explanations : CanvasLayer = $Explanations
@onready var attack_button_highlight : AnimatedSprite2D = $UI/AttackButtonHighlight
@onready var mini_card_highlight : AnimatedSprite2D = $MiniCardHighlight
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
	
]



# === Custom Methods ===========================================================

func balloon_and_connect(starting_loc : String) -> void:
	var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), starting_loc)
	
	# TODO CHANGE
	balloon.skippable = true
	await balloon.char_spoke
	balloon.dialogue_label.started_typing.connect(_on_started_typing)
	balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
	
	await balloon.tree_exited

func wait(sec : float) -> Signal:
	return await get_tree().create_timer(sec).timeout
	
func initialize() -> void:
	
	await balloon_and_connect("start")
	
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
		await balloon_and_connect("hint_grab_new_card")
		weapons_display.play("draw_highlight")
		return
	
	if force_equip_rank > 0 and mini_card:
		if !highlighted_card:
			push_error("Forcing to pick rank but no highlighted card")
			return
			
		if mini_card.rank != force_equip_rank:
			await balloon_and_connect("hint_equip_crit_card")
			highlight_mini_card(highlighted_card)
			return
	
	# Stop highlighting anim if not needed once equipped
	mini_card_highlight.hide()
	
	super(mini_card, player_update)
	
	
	if mini_equipped and !grabbed_last_card:
		match cards_left_on_ground:
			3: # Picked up the first DAGGER
				if mini_equipped.rank != 2 or equipped_first_card:
					return
				
				await balloon_and_connect("equip_first_card")
				equipped_first_card = true
				
				# Show when equipping for first time
				chain_button.hide()
				await tutorial_ap.animation_finished
				
				
			2: # Picked second ACE
				if mini_equipped.rank != 1 or equipped_second_card:
					return
				await balloon_and_connect("equip_second_card")
				equipped_second_card = true
			1:
				print("test")
				pass
			0: # Picked fourth SPEAR
				if mini_equipped.rank != 3 or equipped_fourth_card:
					return
					
				await balloon_and_connect("equip_fourth_card")
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
	
	# Do specific thing when picked up card
	match cards_left_on_ground:
		3:
			highlight_mini_card(get_tree().get_first_node_in_group("mini_cards"))
		2:
			force_equip_rank = 1
			var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
			var cards_with_force_rank : Array= mini_cards.filter(func(e : MiniCard) -> bool: return e.rank == force_equip_rank)
			if cards_with_force_rank.is_empty():
				push_error("Forcing rank of card that player doesn't have.")
			highlight_mini_card(cards_with_force_rank[0])
		1:
			pass
		0:
			pass
	
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
			tutorial_ap.play("chain_button_show")
			await tutorial_ap.animation_finished
			await get_tree().create_timer(1.0).timeout
			tutorial_ap.play("explain_chain")
			await tutorial_ap.animation_finished
			force_chain_attack = true
			explained_chain = true
		explains.CUT_SOCKET:
			tutorial_ap.play("explain_cut_socket")
			await tutorial_ap.animation_finished
			explained_cut_socket = true
	
	await get_tree().create_timer(5.0).timeout
	pause_input = false


func highlight_mini_card(card : MiniCard = null) -> void:
	highlighted_card = card
	if !card:
		mini_card_highlight.hide()
		mini_card_highlight.stop()
	elif card != mini_equipped:
		mini_card_highlight.global_position = card.global_position
		mini_card_highlight.show()
		mini_card_highlight.play("default")
		await mini_card_highlight.animation_finished
		mini_card_highlight.hide()

func update_crit_button() -> void:
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

func _process(_delta: float) -> void:
	super(_delta)
	if highlighted_card:
		mini_card_highlight.global_position = highlighted_card.sprite2d.global_position
	

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

func _on_attack_button_pressed() -> void:
	if force_chain_attack:
		await balloon_and_connect("hint_chain_attack")
		attack_button_highlight.show()
		attack_button_highlight.play("default")
		await attack_button_highlight.animation_finished
		attack_button_highlight.hide()
		return
	super()

func _on_chain_button_pressed() -> void:
	super()
	force_chain_attack = false

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
	
	
	player.play("base_idle")
	
	pause_input = false

func _on_weapon_combat_fin(_weapon : Weapon) -> void:
	super(_weapon)
	if equipped_first_card and !hinted_grab_new_card:
		await balloon_and_connect("hint_grab_new_card")
		force_grab_card = true
		hinted_grab_new_card = true 

func _on_enemy_freed(_enemy : Enemy) -> void:
	super(_enemy)
	enemy_freed_counter += 1
	
	match enemy_freed_counter:
		1: # Killed first enemy with Ace and crit
			force_equip_rank = 0
			highlighted_card = null
		2: # Killed second 2
			if cards_left_on_ground > 1:		# hasnt picked up the 2 2's and Ace
				force_grab_card = true
			explain(explains.CHAIN)


func _on_explanations_gui_input(event: InputEvent) -> void:
	_unhandled_input(event)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"explain_hide":
			if turn_clock.visible == false:
				tutorial_ap.play("attack_buttons_show")
				await tutorial_ap.animation_finished
