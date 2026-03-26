extends Node

var met_kod : bool = false

func save() -> Dictionary:
	var dict : Dictionary = {
		"met_kod" = met_kod
	}
	return dict

func load_save(dict : Dictionary) -> void:
	for key : String in dict.keys():
		set(key, dict[key])
