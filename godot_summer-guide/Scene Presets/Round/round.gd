extends Node

# Player
var suit = Card.Suits.HEART
var player_card_hp : int = 5
const max_cards : int = 4

# Energy System
var joker_energy : int = 5
const max_energy : int = 5
var ace_curr_charge : int = 0    # Tracks how many Ace Charges Filled
const aces_needed : int = 3
var ace_charges : Array[AnimatedSprite2D]

# Card Positions
var first_card_pos = Vector2(100,152)
var enemy_card_pos : Array[Vector2] = [Vector2(149,46), Vector2(134,36), Vector2(157,26)]

# Actions
var actioned : bool = false
var card_selected : bool = false

# Node Tracking
var player_cards : Dictionary
var enemy_cards : Dictionary

# Decoration
@onready var suit_zone : Sprite2D = $Deco/SuitZone
@onready var active_zone : Sprite2D = $Deco/ActiveCardZone
@onready var round_label : Label = $UI/RoundLabel
@onready var red_joker : AnimatedSprite2D = $Deco/RedJoker
@onready var ace_charge1 = $Deco/AceCharge1
@onready var ace_charge2 = $Deco/AceCharge2
@onready var ace_charge3 = $Deco/AceCharge3

# UI
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


func reset_cards_pos():
	for card : Card in player_cards:
		card.position = Vector2(first_card_pos.x + 35 * player_cards[card], first_card_pos.y)
		card.is_card_attacking = false

func combat():
	for card : Card in player_cards:
		if card.is_card_attacking:
			card.AP_play("player_attack")
			card.damage()
			match card.rank:
				1:
					charge_ace_up()

func spawn_enemies(count : int = 2):
	#for i in range(1):
		#Card.new_random_card(range(13), suit)
		#Card.pos
		pass

func charge_ace_up():
	ace_curr_charge += 1
	for ace_charge in ace_charges:
		if int(ace_charge.name.erase(0,9)) == ace_curr_charge:
			ace_charge.play("fill")
			

# === Built In =================================================================

func _ready() -> void:
	joker_energy = max_energy
	
	# Nodes
	signal_setup()
	ace_charges = [ace_charge1,ace_charge2,ace_charge3]
	
	# UI
	suit_zone.frame = suit
	round_label.text = "Round: 1/10"
	joker_energy_label.text = "Joker Energy: " + str(joker_energy)
	
	
# === Signals ==================================================================

func _on_atk_button_down():
	var attacking_card = false
	for card : Card in player_cards:
		if card.is_card_attacking:
			attacking_card = true
	if !attacking_card:
		console_log.display_text("Must pick card")
		return
	combat()
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
			reset_cards_pos()

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
			reset_cards_pos()
	
func _on_draw_button_down():
	
	# Checks
	if joker_energy < 1:
		console_log.display_text("None Remaining")
		return
		
	if len(player_cards) >= max_cards:
		console_log.display_text("Max cards")
		return
	
	if actioned:
		console_log.display_text("No more actions")
		return
	actioned = true
	
	
	# Card Setup
	var card : Card = Card.new_random_card(range(1,5), Card.Suits.DIAMOND)
	
	for i in range(4):
		if player_cards.find_key(i) == null:
			player_cards[card] = i
			break

	card.name = "PlayerCard" + str(len(player_cards))
	card.is_player_card = true
	reset_cards_pos()
	add_child(card)
	card.set_hp(player_card_hp)
	
	# Connect card signals
	var card_area2d : Area2D = card.area2d
	card_area2d.input_event.connect(_on_area2d_input.bind(card))
	card.dead.connect(_on_card_dead)
	card.animation_finished.connect(_on_card_animation_finished)
	
	# Update UI
	joker_energy -= 1
	joker_energy_label.text = "Joker Energy: " + str(joker_energy)
	
	
	
	# DECO
	red_joker.play("summon")

func _on_card_dead(node : Card):
	player_cards.erase(node)
	
	
# DECO
func _on_red_joker_animation_finished():
	red_joker.play("default")
	
func _on_ace_charge3_animation_finished():
	if ace_curr_charge != 3:
		return
	
	joker_energy = max_energy
	ace_curr_charge = 0
	
	
	# UI
	# Reset nodes
	for ace_charge in ace_charges:
		ace_charge.play("default")
	joker_energy_label.text = "Joker Energy: " + str(joker_energy)
	
	red_joker.play("phew")
	joker_energy_label.flash()

func _on_card_animation_finished(_card : Card, anim : String):
	if anim != "RESET":
		_card.AP_play("RESET")
	reset_cards_pos()
