class_name Loot
extends Resource

@export var item : Item
@export var min_amount : int
@export var max_amount : int
@export var drop_chance : float

func get_amount() -> int:
	return randi_range(min_amount, max_amount)
