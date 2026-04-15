extends Node

# Internal
var rounds_per_suit : int = 7
const spread_location : Array = ["hearts", "clubs", "spades"]

# ==============================================================================
# ADD TO SAVE DICT
# Perma save data
# ==============================================================================
var tutorial_completed : bool = false

# Run save data
# ==============================================================================
var seed_data : int

var force_encounters : Array				## Force specific encounters in next CHOOSE_ENCOUNTER. <= 3 Globals.scenes
var force_gift_weapon : String				## Force KOD to give specific weapon
var forced_battles_in_row : int = 0 		## Number of battles given to by game in a row
var last_encounter : Globals.scenes
var unlocked_journal : bool = false
var gained_first_special : bool = false
var unlocked_memory : bool = false

var unlocked_rank : int = 0
var player_location : Dictionary = {
	"spread_location" = spread_location[0],
	"round" = 7
}
var map_last_pos : float

# NPC Meetings
var met_kod : bool = false
var given_kod_core : bool = false

var met_qod : bool = false
# ==============================================================================
## Tracks data for current run
func save() -> Dictionary:
	var dict : Dictionary = {
		"seed" = seed,
		
		"force_encounters" = force_encounters,
		"forced_battles_in_row" = forced_battles_in_row,
		"last_encounter" = last_encounter,
		"unlocked_journal" = unlocked_journal,
		"gained_first_special" = gained_first_special,
		"unlocked_memory" = unlocked_memory,
		
		"unlocked_rank" = unlocked_rank,
		"player_location" = player_location,
		"map_last_pos" = map_last_pos,
		"met_kod" = met_kod,
		"given_kod_core" = given_kod_core,
		"met_qod" = met_qod
	}
	return dict

## Tracks data for whole game
func perma_save() -> Dictionary:
	var dict : Dictionary = {
		"tutorial_completed" = tutorial_completed
	}
	return dict

func load_save(dict : Dictionary) -> void:
	for key : String in dict.keys():
		set(key, dict[key])
