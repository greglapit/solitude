extends Node2D

@onready var player : Node2D = $Player
@onready var mini_card_selector : Control = $UI/MiniCardSelector

var deck : Array[Card]
var mini_pos : Array[Vector2]

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	mini_pos = mini_card_selector.get_mini_pos()
	for pos in mini_pos():
		Card.new_random_card()
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
