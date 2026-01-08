extends Control

@onready var panel1 : Panel = $MarginContainer/HBoxContainer/Panel
@onready var panel2 : Panel = $MarginContainer/HBoxContainer/Panel2
@onready var panel3 : Panel = $MarginContainer/HBoxContainer/Panel3
@onready var panel4 : Panel = $MarginContainer/HBoxContainer/Panel4
@onready var panel5 : Panel = $MarginContainer/HBoxContainer/Panel5

func get_mini_pos() -> Array:
	var positions : Array = [panel1.global_position, panel2.global_position, panel3.global_position, panel4.global_position, panel5.global_position]
	
	# Changes positions to center
	positions = positions.map(func(v: Vector2) -> Vector2: return v + (panel1.size * .5))
		
	return positions
