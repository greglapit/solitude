extends Node

# Internal
var rounds_per_suit : int = 5

# Saveable
var player_location : Dictionary = {
	"suit" = "hearts",
	"round" = 0
}
var map_last_pos : float
var met_kod : bool = false
var given_kod_core : bool = false

func save() -> Dictionary:
	var dict : Dictionary = {
		"player_location" = player_location,
		"map_last_pos" = map_last_pos,
		"met_kod" = met_kod,
		"given_kod_core" = given_kod_core
	}
	return dict

func load_save(dict : Dictionary) -> void:
	for key : String in dict.keys():
		set(key, dict[key])
