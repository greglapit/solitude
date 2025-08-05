extends Node

# Player
@export var immune : bool = false # Used for debugging
var player_hp : float = 100
var hp_shield : bool = false
var player_card_hp : int = 3
var attacking_card : Card
const max_cards : int = 4
const max_enemies : int = 3

# Round
var suit = Card.Suits.HEART
var boss : Node2D
var boss_card : Card
var boss_scene : PackedScene
var boss_list : Array = ["queen_hearts", "queen_hearts", "queen_hearts"]
var curr_round : int
var boss_round : int = 5
var player_card_range : Array = range(1,5) # Which suits enemy and player can generate
var enemy_card_range : Array = range(1,11)

# Energy System
var joker_energy : int
const max_energy : int = 100
var ace_curr_charge : int = 0    # Tracks how many Ace Charges Filled
const aces_needed : int = 3
var ace_charges : Array[AnimatedSprite2D]

# Card Positions
var first_card_pos = Vector2(120*2,152*2)
var enemy_card_pos : Array[Vector2] = [Vector2(320,110), Vector2(290,90), Vector2(340,70)]

# Actions
var actioned : bool = false
var card_selected : bool = false
var card_queued : bool = false # Checks if card is queued to player inventory after current card dies

# Node Tracking
var player_cards : Dictionary
var enemy_cards : Array[Node]

# Decoration
@onready var suit_zone : Sprite2D = $Deco/SuitZone
@onready var active_zone : Sprite2D = $Deco/ActiveCardZone
@onready var round_label : Label = $UI/RoundLabel
@onready var red_joker : AnimatedSprite2D = $Deco/RedJoker
@onready var ace_charge1 = $Deco/AceCharges/AceCharge1
@onready var ace_charge2 = $Deco/AceCharges/AceCharge2
@onready var ace_charge3 = $Deco/AceCharges/AceCharge3

# UI
@onready var gg_notif : CanvasLayer = $UI/GGNotif
@onready var tooltip : PanelContainer = $UI/Tooltip
@onready var help_screen : CanvasLayer = $UI/HelpScreen
@onready var death_notif : CanvasLayer = $UI/DeathNotif
@onready var screen_cover : ColorRect = $ScreenCover
@onready var hp_bar : PanelContainer = $UI/Health
@onready var boss_hp_bar : PanelContainer = $UI/BossHealth
@onready var joker_energy_label : Label = $UI/JokerEnergy
@onready var console_log : TextEdit = $UI/ConsoleLog
@onready var atk_button : TextureButton = $UI/Atk
@onready var sharpen_button : Button = find_child("Sharpen")
@onready var chip_button : Button = find_child("Chip")
@onready var draw_button : Button = find_child("Draw")

# === Custom Methods ===========================================================

func signal_setup():
	atk_button.button_down.connect(_on_atk_button_down)
	sharpen_button.button_down.connect(_on_sharpen_button_down)
	chip_button.button_down.connect(_on_chip_button_down)
	draw_button.button_down.connect(_on_draw_button_down)
	
	# Deco 
	red_joker.animation_finished.connect(_on_red_joker_animation_finished)
	ace_charge3.animation_finished.connect(_on_ace_charge3_animation_finished)
	screen_cover.screen_black.connect(_on_screen_cover_screen_black)


func reset_cards_pos():
	for card : Card in player_cards:
		card.position = Vector2(first_card_pos.x + 50 * player_cards[card], first_card_pos.y)
		card.is_card_attacking = false
	
func reset_enemy_cards_pos():
	if curr_round == boss_round:
		return
	var i : int = 0
	for enemy_card : Card in enemy_cards:
		enemy_card.position = enemy_card_pos[i]
		enemy_card.z_index = -i
		i += 1

func card_combat():
	var enemy_target : Card = enemy_cards[0]
	enemy_target.is_card_attacking = true
	for player_card : Card in player_cards:
		if player_card.is_card_attacking:
			
			player_card.AP_play("player_attack")
			player_card.damage()
			
			var difference = enemy_target.rank - player_card.rank
			# Player
			
			var shielded_this_turn : bool = false    # Prevents protecting from damage during this current turn
			
			# Enemy
			match player_card.rank:
				1:
					if enemy_target.rank == 1:
						charge_ace_up()
					charge_ace_up()
					enemy_target.damage(1)
				2:
					if enemy_target.rank % 2 == 0:
						difference -= 4
						enemy_target.damage(6)
					else:
						enemy_target.damage(2)
				3:
					if enemy_target.rank % 2 == 1:
						difference -= 3
						enemy_target.damage(6)
					else:
						enemy_target.damage(3)
				4:
					enemy_target.damage(4)
					if !hp_shield:
						shielded_this_turn = true
					hp_shield = true
			
			if curr_round == boss_round:
				boss_hp_bar.display_health(max(enemy_target.hp * 2, 0), boss.starting_health)
				match boss.name:
					"QueenHearts":
						hp_shield = false
						hp_bar.health_shield(false)
						return # Queen only attacks player through scream
			
			# Done after enemy so damage could be adjusted for "effective" interactions
			if difference > 0:
				if shielded_this_turn or !hp_shield:
					player_hp -= max(0,difference*5)
				else:
					hp_shield = false
			return

func boss_combat():
	match boss.name:
		"QueenHearts":
			if boss.scream_counter <= 1:
				for card : Card in player_cards:
					if card.rank > 1:
						card.chip()
					card.damage()
				for card : Card in player_cards:
					card.check_dead()
					
				player_hp -= 25
				hp_update()
	boss.combat()
	card_combat()
	
	if boss_card.hp <= 0:
		curr_round += 1
		for card in enemy_cards:
			card.queue_free()
		enemy_cards.clear()
		screen_cover.fade_black()

func hp_update():
	hp_bar.display_health(player_hp)
	if player_hp < 1:
		death_notif.visible = true
	hp_bar.health_shield(hp_shield)

func check_round_end():
	if enemy_cards.size() != 0:
		return
	curr_round += 1
	reset_cards_pos()
	
	# Boss Starting
	if curr_round == boss_round:
		
		start_boss()
	elif curr_round < boss_round:
		round_label.text = "Round: " + str(curr_round) + "/" + str(boss_round)
		spawn_enemies(3)

func spawn_enemies(count : int = 3):
	var starting_spot = len(enemy_cards)
	for i in count:
		var card_place = starting_spot + i
		if card_place >  max_enemies:
			print("Cant Spawn Enemy")
			return
		enemy_card_range = range(curr_round, 11)
		var card = Card.new_random_card(enemy_card_range, suit)
		
		# Properties
		card.position = enemy_card_pos[card_place]
		card.scale = Vector2(2,2)
		card.z_index = -card_place
		card.power_incr = max(randi() % 3 - 1, 0)
		
		# Signals
		card.animation_finished.connect(_on_card_animation_finished)
		card.dead.connect(_on_card_dead)

		enemy_cards.append(card)
		add_child(card)

func start_boss():
	curr_round = boss_round
	for enemy in enemy_cards:
		enemy.queue_free()
	enemy_cards.clear()
	boss_card = Card.new_card(Card.Suits.HEART, 12)
	boss_card.visible = false
	add_child(boss_card)
	enemy_cards.append(boss_card)
	enemy_cards[0].is_boss_card = true
	screen_cover.fade_black() # Handles boss event starting in signal below

func charge_ace_up():
	ace_curr_charge += 1
	for ace_charge in ace_charges:
		if int(ace_charge.name.erase(0,9)) == ace_curr_charge:
			ace_charge.play("fill")

func summon_card():
	# Checks
	if joker_energy < 1:
		red_joker.play("phew")
		return
	if len(player_cards) >= max_cards:
		return
	
	# Card Setup
	var card : Card = Card.new_random_card(player_card_range, Card.Suits.DIAMOND)
	
	for i in range(4):
		if player_cards.find_key(i) == null:
			player_cards[card] = i
			break

	card.name = "PlayerCard" + str(len(player_cards))
	card.is_player_card = true
	card.position = Vector2(first_card_pos.x + 50 * player_cards[card], first_card_pos.y)
	add_child(card)
	card.set_hp(player_card_hp)
	
	# Connect card signals
	var card_area2d : Area2D = card.area2d
	
	# Signals
	card_area2d.input_event.connect(_on_area2d_input.bind(card))
	card.dead.connect(_on_card_dead)
	card.animation_finished.connect(_on_card_animation_finished)
	
	# Update UI
	joker_energy -= 1
	joker_energy_label.text = "Joker Energy: " + str(joker_energy)
	
	# DECO
	red_joker.play("summon")

func reset_energy():
	joker_energy = max_energy
	ace_curr_charge = 0
	
	# UI
	for ace_charge in ace_charges:
		ace_charge.play("default")
	joker_energy_label.text = "Joker Energy: " + str(joker_energy)
	
	red_joker.play("phew")
	joker_energy_label.flash()

func new_game():
	# Player
	player_hp = 100
	hp_shield = false

	# Round
	curr_round = 1
	if boss:
		boss.queue_free()
		boss_hp_bar.visible = false

	# Energy System
	joker_energy = max_energy
	ace_curr_charge = 0 

	# Actions
	actioned = false
	card_selected = false
	card_queued = false
	
	joker_energy = max_energy
	
	for card in player_cards:
		card.queue_free()
	for card in enemy_cards:
		if card:
			card.queue_free()
	player_cards.clear()
	enemy_cards.clear()
	
	# Nodes
	reset_energy()
		
	# Enemies
	spawn_enemies()
	
	# UI
	hp_bar.display_health(player_hp)
	hp_bar.health_shield(false)
	boss_hp_bar.visible = false
	suit_zone.frame = suit
	round_label.text = "Round: " + str(curr_round) + "/" + str(boss_round)
	joker_energy_label.text = "Joker Energy: " + str(joker_energy)
	death_notif.visible = false
	tooltip.visible = false
	gg_notif.visible = false
	screen_cover.reset()


# === Built In =================================================================

func _ready() -> void:
	signal_setup()
	ace_charges = [ace_charge1, ace_charge2, ace_charge3]
	match boss_list[randi() % 3]:
		"queen_hearts":
			boss_scene = load("res://Entities/Queens/Hearts/queen_hearts.tscn")
	new_game()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_game"):
		new_game()
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
	if event.is_action_pressed("help_screen"):
		if curr_round == boss_round:
			help_screen.visible = false
			tooltip.visible = !tooltip.visible
		else:
			help_screen.visible = !help_screen.visible
	if event.is_action_pressed("start_boss"):
		start_boss()
	

# === Signals ==================================================================

func _on_atk_button_down():
	attacking_card = null
	for card : Card in player_cards:
		if card.is_card_attacking:
			attacking_card = card
	if !attacking_card:
		console_log.display_text("Must pick card")
		return
		
	# Draw for player if they havent used action
	if !actioned && len(player_cards) >= max_cards:
		card_queued = true
	elif !actioned:
		summon_card()
	
	if curr_round != boss_round:
		card_combat()
	else:
		boss_combat()
	
		
	actioned = false

func _on_area2d_input(_viewport: Node, event: InputEvent, _shape_idx: int, card : Card):
	if event is InputEventMouseButton:
		if card.is_player_card == false:
			return
		
		# Move to active card slot
		if event.double_click == true:
			reset_cards_pos()
			card.position = active_zone.position
			card.is_card_attacking = true
			card.deselect()
			card_selected = false
			return
		
		# Select/Deseslect cards
		for player_card in player_cards:
			player_card.deselect()
		card_selected = true
		card.select()

func _on_sharpen_button_down():
	if actioned:
		console_log.display_text("No more actions")
		return
	if card_selected == false:
		console_log.display_text("Must pick card")
		return
	for card in player_cards:
		if card.selected == true:
			if card.rank > 13 or card.hp < 2:
				console_log.display_text("Invalid")
				return
			actioned = true
			card.sharpen()
			card.damage()

func _on_chip_button_down():
	if actioned:
		console_log.display_text("No more actions")
		return
	if card_selected == false:
		console_log.display_text("Must pick card")
		return
	for card in player_cards:
		if card.selected == true:
			if card.rank < 2 or card.hp < 2:
				console_log.display_text("Invalid")
				return
			actioned = true
			card.chip()
			card.damage()
	
func _on_draw_button_down():
	
	# Checks
	if joker_energy < 1:
		console_log.display_text("No energy")
		red_joker.play("phew")
		return
		
	if len(player_cards) >= max_cards:
		console_log.display_text("Max cards")
		return
	
	if actioned:
		console_log.display_text("No more actions")
		return
	actioned = true
	
	summon_card()

func _on_card_dead(node : Card):
	if node in enemy_cards:
		enemy_cards.pop_front()
		#reset_enemy_cards_pos()
		#reset_cards_pos()
		#check_round_end()
		hp_update()
		
	if node in player_cards:
		player_cards.erase(node)
		
		if card_queued:
			summon_card()

func _on_card_animation_finished(_card : Card, anim : String):
	if _card.is_player_card:
		match anim:
			"delayed_chip":
				_card.AP_play("RESET")
				reset_cards_pos()
			"player_attack":
				_card.AP_play("RESET")
				if curr_round == boss_round:
					reset_cards_pos()
					hp_update()
				reset_enemy_cards_pos()
				check_round_end()
			_:
				_card.AP_play("RESET")
				reset_enemy_cards_pos()
				check_round_end()
	if !_card.is_player_card && _card == enemy_cards[0]:
		match anim:
			"delayed_chip":
				_card.AP_play("enemy_attack")
				if attacking_card:
					attacking_card.AP_play("delayed_chip")
			"enemy_attack":
				hp_update()
			_:
				pass

func _on_screen_cover_screen_black():
	if curr_round != boss_round:
		boss.queue_free()
		boss = null
		gg_notif.visible = true
		return
	var _boss = boss_scene.instantiate()
	_boss.position = Vector2(320,100)
	round_label.text = "Round: BOSS"
	
	
	add_child(_boss)
	boss = _boss
	_boss.anim_finished.connect(_on_boss_anim_finished)
	
	enemy_cards[0].hp = 50 # Pair with hidden boss card which is used for combat functionality
	
	
func _on_boss_anim_finished(anim : String):
	match anim:
		"spawn":
			boss_hp_bar.visible = true
			boss_hp_bar.display_health(100, 50)
			screen_cover.reset()
			tooltip.visible = true
		_:
			pass

# DECO
func _on_red_joker_animation_finished():
	red_joker.play("default")
	
func _on_ace_charge3_animation_finished():
	if ace_curr_charge >= aces_needed:
		player_hp = min(100.0, player_hp + 15.0)
		hp_update()
		reset_energy()
