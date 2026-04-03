extends Node

# Internal
var rounds_per_suit : int = 5

# ==============================================================================
# ADD TO SAVE DICT
var unlocked_rank : int = 0
var player_location : Dictionary = {
	"suit" = "hearts",
	"round" = 0
}
var map_last_pos : float

# NPC Meetings
var met_kod : bool = false
var given_kod_core : bool = false

var met_qod : bool = false
# ==============================================================================

func save() -> Dictionary:
	var dict : Dictionary = {
		"unlocked_rank" = unlocked_rank,
		"player_location" = player_location,
		"map_last_pos" = map_last_pos,
		"met_kod" = met_kod,
		"given_kod_core" = given_kod_core,
		"met_qod" = met_qod
	}
	return dict

func load_save(dict : Dictionary) -> void:
	for key : String in dict.keys():
		set(key, dict[key])
