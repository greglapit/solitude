extends Node

var player_cards : Dictionary
var player_card_hp : int = 3
var max_cards : int = 4
var first_card_pos = Vector2(100,152)

@onready var console_log : TextEdit = find_child("ConsoleLog")
@onready var sharpen_button : Button = find_child("Sharpen")
@onready var chip_button : Button = find_child("Chip")
@onready var draw_button : Button = find_child("Draw")

# Custom Methods

func signal_setup():
	sharpen_button.button_up.connect(_on_sharpen_button_up)
	chip_button.button_up.connect(_on_chip_button_up)
	draw_button.button_up.connect(_on_draw_button_up)

func reset_cards_pos():
	for card in player_cards:
		card.position = Vector2(first_card_pos.x + 35 * player_cards[card], first_card_pos.y)


# Built In

func _ready() -> void:
	signal_setup()
	
	
# Signals

func _on_area2d_input(viewport: Node, event: InputEvent, shape_idx: int, card : Card):
	if event is InputEventMouseButton:
		for player_card in player_cards:
			player_card.deselect()
		card.select()

func _on_sharpen_button_up():
	for card in player_cards:
		if card.selected == true:
			if card.hp == 1: # TODO Not sure if I like Round node handling this. Using round node to handle so it can update player_cards easily
				player_cards.erase(card)
			card.sharpen()
			card.damage()
			reset_cards_pos()

func _on_chip_button_up():
	for card in player_cards:
		if card.selected == true:
			if card.hp == 1: # TODO Not sure if I like Round node handling this. Using round node to handle so it can update player_cards easily
				player_cards.erase(card)
			card.chip()
			card.damage()
			reset_cards_pos()
	
func _on_draw_button_up():
	if len(player_cards) >= max_cards:
		console_log.display_text("Max cards")
		return
	var card : Card = Card.new_random_card(range(1,5), Card.Suits.DIAMOND)
	
	for i in range(4):
		if player_cards.find_key(i) == null:
			player_cards[card] = i
			break
		

	card.name = "PlayerCard" + str(len(player_cards))
	reset_cards_pos()
	add_child(card)
	card.hp = player_card_hp
	
	# Connect card signals
	var card_area2d : Area2D = card.area2d
	card_area2d.input_event.connect(_on_area2d_input.bind(card))
