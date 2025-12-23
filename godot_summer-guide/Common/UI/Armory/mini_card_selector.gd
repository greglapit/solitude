extends Control

@onready var panel1 : Panel = $MarginContainer/HBoxContainer/Panel
@onready var panel2 : Panel = $MarginContainer/HBoxContainer/Panel2
@onready var panel3 : Panel = $MarginContainer/HBoxContainer/Panel3
@onready var panel4 : Panel = $MarginContainer/HBoxContainer/Panel4
@onready var panel5 : Panel = $MarginContainer/HBoxContainer/Panel5

func get_mini_pos() -> Array[Vector2]:
	var positions = [panel1.position, panel2.position, panel3.position, panel4.position, panel5.position]
	return positions
