extends Node

var card := Card.new_card(Card.Suits.CLUB, 1)

func _ready():
	pass
	
func _process(delta: float) -> void:
	var card := Card.random_card()
	add_child(card)
	card.position = Vector2(160,85)
	set_process(false)
	await get_tree().create_timer(1.0).timeout
	set_process(true)
	card.queue_free()
