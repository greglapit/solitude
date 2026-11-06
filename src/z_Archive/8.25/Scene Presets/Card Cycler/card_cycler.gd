extends Node

# Obselete
func card_cycler(position : Vector2):
	while true:
		var card : Card = Card.new_random_card()
		add_child(card)
		card.position = position
		await get_tree().create_timer(1.0).timeout
		card.queue_free()

func _ready():
	card_cycler(Vector2(94,152))
	card_cycler(Vector2(136,153))
	card_cycler(Vector2(181,153))
	card_cycler(Vector2(220,153))
	
func _process(delta: float) -> void:
	pass
