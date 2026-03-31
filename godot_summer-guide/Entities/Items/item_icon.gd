@tool
class_name ItemIcon
extends TextureRect

@export var item: Item:
	set(value):
		item = value
		_update_icon()

func _ready() -> void:
	_update_icon()

func _update_icon() -> void:
	if not is_inside_tree():
		return
	if item and item.texture:
		texture = item.texture
	else:
		texture = null
