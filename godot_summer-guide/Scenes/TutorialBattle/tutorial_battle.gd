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
var generated_first_time : bool = false
var reached_max_hand : bool = false
enum explains {
	INITIATIVE,
	CHAIN,
	CUT_SOCKET
}
var grabbed_last_card : bool = false
var enemy_freed_counter : int = 0
var allowed_draw : bool = false
var finished_tutorial : bool = false

var force_grab_card : bool = false		# Force player to grab card
var force_equip_rank : int = 0 			# Card rank to be forced to equip
var force_chain_attack : bool = false	# Force player to pick chain
var force_cut : bool = false

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
		"durability" = 2
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
	
	# Second Set of enemies
		{
		"rank" = 3,
		"true_rank" = 3
	},
	{
		"rank" = 2,
		"true_rank" = 2
	},
	{
		"rank" = 1,
		"true_rank" = 1
	},
]



# === Custom Methods ===========================================================

func balloon_and_connect(starting_loc : String) -> void:
	var balloon : Balloon = DialogueManager.show_dialogue_balloon_scene("res://Scenes/UI/TextBox/battle_balloon.tscn",load("res://Scenes/TutorialBattle/tutorial.dialogue"), starting_loc)
	
	# TODO CHANGE false
	balloon.skippable = false
	await balloon.char_spoke
	balloon.dialogue_label.started_typing.connect(_on_started_typing)
	balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
	
	await balloon.tree_exited

func play(anim : String) -> void:
	tutorial_ap.queue(anim)

func wait(sec : float) -> Signal:
	return await get_tree().create_timer(sec).timeout
	
func initialize() -> void:
	
	await balloon_and_connect("start")
	
	play("draw_button_show")
	await tutorial_ap.animation_finished
	weapons_display.play("draw_highlight")
	pause_input = false

func end_battle() -> void:
	equip_mini_card(null)
	# Break all player cards
	var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
	for mini_card : MiniCard in mini_cards:
		mini_card.damage(mini_card.durability)
	player.play("base_dazed")
	await get_tree().create_timer(3.0).timeout
	
	ProgressTracker.force_encounters = [Globals.scenes.KOD]
	ProgressTracker.force_gift_weapon = "1_philo_weapon"
	change_scn.emit(Globals.scenes.CAMP, false, false)


func equip_mini_card(mini_card : MiniCard = null, player_update : bool = true) -> void:
	if mini_card and force_grab_card:
		await balloon_and_connect("hint_grab_new_card")
		weapons_display.play("draw_highlight")
		return
	
	if mini_card and force_equip_rank > 0:
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
	
	if !explained_cut_socket:
		weapons_display.socket_button.hide()
		weapons_display.cut_button.hide()
	
	if mini_equipped and (!grabbed_last_card or !equipped_fourth_card):
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
				pass
			0: # Picked fourth SPEAR
				if mini_equipped.rank != 3 or equipped_fourth_card:
					return
				
				await balloon_and_connect("equip_fourth_card")
				equipped_fourth_card = true
				
	if finished_tutorial and !reached_max_hand:
		var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
		if mini_cards.size() == Globals.max_draw:
			await balloon_and_connect("reached_max_hand")
			reached_max_hand = true


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
		

func spawn_enemy(num : int = 1, enemy_data : Dictionary = {}) -> void:
	if tutorial_enemies.is_empty():
		super(num, enemy_data)
		return
	
	var tutorial_enemies_left : int = min(tutorial_enemies.size(), 3)
	var left_over : int = num - tutorial_enemies_left 					# If didn't spawn 3 tutorial enemies
	for i : int in range(tutorial_enemies_left):
		super(1, tutorial_enemies[0])
		tutorial_enemies.remove_at(0)
		await get_tree().create_timer(0.2).timeout
	
	if left_over >= 1:
		super(left_over)

# No tatters from first fight
func update_tatters() -> void:
	pass


func explain(scn : explains) -> void:
	if explanations.visible:
		return
	pause_input = true
	match scn:
		explains.INITIATIVE:
			play("explain_initiative")
			await tutorial_ap.animation_finished
			explained_initiative = true
		explains.CHAIN:
			play("chain_button_show")
			await tutorial_ap.animation_finished
			await get_tree().create_timer(1.0).timeout
			play("explain_chain")
			await tutorial_ap.animation_finished
			force_chain_attack = true
			explained_chain = true
		explains.CUT_SOCKET:
			explained_cut_socket = true
			play("cut_socket_show")
			await tutorial_ap.animation_finished
			play("explain_cut_socket")
			await tutorial_ap.animation_finished
			equip_mini_card(mini_equipped)
			force_cut = true
	
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
	#end_battle()
	
	super()
	weapons_display.joker.hide()
	weapons_display.draw_button.hide()
	attack_buttons_ui.hide()
	turn_clock.hide()
	health_bar.hide()
	tatter_count.hide()
	hands_label.hide()
	
	player.play("tutorial_laying")
	player.animation_player.seek(player.animation_player.current_animation.length()/2.)
	weapons_display.draw_button_label.text = "Grab Card"

func _process(_delta: float) -> void:
	super(_delta)
	if highlighted_card:
		mini_card_highlight.global_position = highlighted_card.sprite2d.global_position
	

func _unhandled_input(event: InputEvent) -> void:
	if pause_input:
		return
	if event.is_pressed() and explanations.visible:
		pause_input = true
		play("explain_hide")
		get_viewport().set_input_as_handled()
		await tutorial_ap.animation_finished
		pause_input = false
		return
	#super(event)
	

# === Signals ==================================================================


func _on_started_typing() -> void:
	weapons_display.play("joker_talking")
	
func _on_finished_typing() -> void:
	weapons_display.play("joker_idle")
	
func _on_weapon_display_update() -> void:
	super()
	if finished_tutorial and hands_label.visible == false:
		await weapons_display.animation_player.animation_finished
		await balloon_and_connect("generated_first_time")
		weapons_display.play("joker_crit_expend")
		play("hands_label_show")
		await tutorial_ap.animation_finished
	
func _on_attack_button_pressed() -> void:
	if force_cut:
		await balloon_and_connect("hint_cut")
		attack_button_highlight.global_position = Vector2(694,434)
		attack_button_highlight.show()
		attack_button_highlight.play("default")
		await attack_button_highlight.animation_finished
		return
	if force_chain_attack:
		await balloon_and_connect("hint_chain_attack")
		attack_button_highlight.global_position = Vector2(601,461)
		attack_button_highlight.show()
		attack_button_highlight.play("default")
		await attack_button_highlight.animation_finished
		attack_button_highlight.hide()
		return
	super()

func _on_chain_button_pressed() -> void:
	if force_cut:
		await balloon_and_connect("hint_cut")
		attack_button_highlight.global_position = Vector2(694,434)
		attack_button_highlight.show()
		attack_button_highlight.play("default")
		await attack_button_highlight.animation_finished
		return
	super()
	force_chain_attack = false

func _on_draw_button_pressed() -> void:
	force_grab_card = false
	if grabbed_last_card:
		if allowed_draw:
			super()
		else:
			balloon_and_connect("no_more_cards_left")
		return
	
	if pause_input:
		return
		
	pause_input = true
	actions -= 1
	weapons_display.buttons_enabled(false)
	weapons_display.play("RESET")
	player.play("tutorial_grab_cards")
	await player.anim_finished
	spawn_tutorial_card(1)
	
	
	player.play("base_idle")
	
	pause_input = false

func _on_cut_button_pressed() -> void:
	super()
	force_cut = false

func _on_weapon_combat_fin(_weapon : Weapon, block_unequip : bool = false) -> void:
	if finished_tutorial:
		super(_weapon, block_unequip)
		return
	
	var play_first_time_draw : bool = false
	
	match enemy_freed_counter:
		3:
			block_unequip = true
		4:
			block_unequip = true
		5:
			weapons_display.draw_button_label.text = "Draw"
			allowed_draw = true
			play_first_time_draw = true
			
			
	super(_weapon, block_unequip)
	if equipped_first_card and !hinted_grab_new_card:
		await balloon_and_connect("hint_grab_new_card")
		force_grab_card = true
		hinted_grab_new_card = true 
		
	if play_first_time_draw:
		weapons_display.play("RESET")
		weapons_display.buttons_enabled(false, false)
		await balloon_and_connect("first_time_draw")
		weapons_display.buttons_enabled(true)
		finished_tutorial = true
		force_grab_card = true
		weapons_display.play("draw_highlight")

func _on_enemy_freed(_enemy : Enemy) -> void:
	super(_enemy)
	enemy_freed_counter += 1
	
	match enemy_freed_counter:
		1: # Killed first enemy with Ace and crit
			force_equip_rank = 0
			highlighted_card = null
			force_grab_card = true
		2: # Killed second 2
			explain(explains.CHAIN)
		3: # Killed 5
			equip_mini_card(null)
			# Break all player cards
			var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
			for mini_card : MiniCard in mini_cards:
				mini_card.damage(mini_card.durability)
			if mini_cards.back():
				await mini_cards.back().tree_exited
			
			await balloon_and_connect("weapon_break")
			equip_mini_card(null)
			force_grab_card = true
			weapons_display.play("draw_highlight")
		4:
			explain(explains.CUT_SOCKET)
		5:
			weapons_display.buttons_enabled(false, false)
		6:
			pass

func _on_explanations_gui_input(event: InputEvent) -> void:
	_unhandled_input(event)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"explain_hide":
			if turn_clock.visible == false:
				play("attack_buttons_show")
				await tutorial_ap.animation_finished
