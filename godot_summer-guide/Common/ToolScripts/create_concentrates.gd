# editor_helper.gd
@tool
extends Node

var rank_names : Array = ["Zero", "Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"]


@export var create_new_item : bool = false:
	set(value):
		if value:
			save_custom_resource()
			create_new_item = false # Reset the button

func save_custom_resource() -> void:
	for i : int in range(1,11):
		var new_data : Item = Item.new()
		new_data.name = rank_names[i] + " Concentrate"
		new_data.id = "concentrate" + str(i)
		new_data.max_count = 10
		
		# ResourceSaver is used to write the file to the disk
		ResourceSaver.save(new_data, "res://Entities/Items/Resources/concentrate" + str(i) + ".tres")
