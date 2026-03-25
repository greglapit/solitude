class_name ItemStack

var item : ItemData
var count : int:
	set(value):
		var new_value : int = clamp(value, 0, item.max_count)
		count = new_value

func save() -> Dictionary:
	var dict : Dictionary = {
		"item_id" = item.id,
		"item_path" = "res://Entities/Items/Resources/" + item.id + ".tres",
		"count" = count
	}
	return dict
