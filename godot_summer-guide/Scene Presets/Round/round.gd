extends Node

var player_cards : Array[Card]
var max_cards : int = 4

@onready var sharpen_button : Button = find_child("Sharpen")
@onready var chip_button : Button = find_child("Chip")
@onready var draw_button : Button = find_child("Draw")

func signal_setup():
	sharpen_button.button_up.connect(_on_sharpen_button_up)
	chip_button.button_up.connect(_on_chip_button_up)
	draw_button.button_up.connect(_on_draw_button_up)


func _ready() -> void:
	signal_setup()



func _on_sharpen_button_up():
	print("sharpen button pressed")

func _on_chip_button_up():
	print("chip button pressed")
	
func _on_draw_button_up():
	if max_cards >= 4:
		print("")
	#var card : Card = Card.new_random_card()
