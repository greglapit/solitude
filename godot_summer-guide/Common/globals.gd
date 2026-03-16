extends Node

var ranks : Array = ["0","A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

# Save Dictionaries
var player_data : Dictionary
var scene_data : Dictionary
var entities_data : Dictionary

var hp : int = 20
var max_hp : int = 20
var draw_amt : int = 3
var actions : int = 1
var attacks : int = 1
var max_draw : int = 3			# How many items player can have drawn at a time
var crits_stored : int
var max_crits : int = 3
		# Convert all keys to int automatically
var armory : Dictionary = {1 : "1_philo_weapon", 2 : '2_twin_weapon', 10 : '10_pirate_weapon'}: 
	set(value):
		armory = {}
		for key : String in value.keys():
			var int_key : int = int(key)
			armory[int_key] = value[key]
var learned_ranks : Array = armory.keys()
var memory_capacity : int = 5
var armory_durs : Array = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]

var learned_weapons : Dictionary = {
	'1_base_weapon' : 1, '1_philo_weapon' : 1, '1_seed_weapon' : 1, \
	'2_base_weapon' : 2, '2_twin_weapon' : 2, '2_glass_weapon' : 2, \
	'3_base_weapon' : 3, '3_trident_weapon' : 3, '3_prowler_weapon' : 3, \
	'4_base_weapon' : 4, '4_mirra_weapon' : 4, '4_bastion_weapon' : 4,\
	'5_base_weapon' : 5, '5_claw_weapon' : 5, '5_maw_weapon' : 5,\
	'6_base_weapon' : 6, '6_locklash_weapon' : 6, '6_weaver_weapon' : 6,\
	'7_base_weapon' : 7, '7_vamp_weapon' : 7, '7_severance_weapon' : 7,\
	'8_base_weapon' : 8, '8_splitter_weapon' : 8, '8_cata_weapon' : 8,\
	'9_base_weapon' : 9, '9_cloud_weapon' : 9, '9_cmd_weapon' : 9,\
	'10_base_weapon' : 10, '10_clock_weapon' : 10, '10_pirate_weapon' : 10\
}
var all_weapons : Dictionary = {
	'1_base_weapon' : 1, '1_philo_weapon' : 1, '1_seed_weapon' : 1, \
	'2_base_weapon' : 2, '2_twin_weapon' : 2, '2_glass_weapon' : 2, \
	'3_base_weapon' : 3, '3_trident_weapon' : 3, '3_prowler_weapon' : 3, \
	'4_base_weapon' : 4, '4_mirra_weapon' : 4, '4_bastion_weapon' : 4,\
	'5_base_weapon' : 5, '5_claw_weapon' : 5, '5_maw_weapon' : 5,\
	'6_base_weapon' : 6, '6_locklash_weapon' : 6, '6_weaver_weapon' : 6,\
	'7_base_weapon' : 7, '7_vamp_weapon' : 7, '7_severance_weapon' : 7,\
	'8_base_weapon' : 8, '8_splitter_weapon' : 8, '8_cata_weapon' : 8,\
	'9_base_weapon' : 9, '9_cloud_weapon' : 9, '9_cmd_weapon' : 9,\
	'10_base_weapon' : 10, '10_clock_weapon' : 10, '10_pirate_weapon' : 10\
}

var all_weap_data : Dictionary		## file_name : resources. All modified loaded weapon resources

func fill_placeholders(template: String, vars: Dictionary) -> String:
	for key : String in vars.keys():
		template = template.replace(key, str(vars[key]))
	return template

func update_save_dicts_data() -> void:
	
	# Player
	player_data = {
		"hp" = hp,
		"max_hp" = max_hp,
		"draw_amt" = draw_amt,
		"actions" = actions,
		"attacks" = attacks,
		"max_draw" = max_draw,
		"crits_stored" = crits_stored,
		"max_crits" = max_crits,
		"armory" = armory,
		"learned_ranks" = armory.keys(),
		"memory_capacity" = memory_capacity,
		"armory_durs" = armory_durs
	}
	
	
	# Scene
	var scene_handler : Node = get_tree().get_nodes_in_group("SceneHandler")[0]
	var curr_scene_path : String = scene_handler.get_child(0).scene_file_path
	scene_data = {
		"curr_scene_path" = curr_scene_path
	}
	
	
	# Entities
	entities_data.clear()
	var save_entities : Array[Node] = get_tree().get_nodes_in_group("persist")
	for node : Node in save_entities:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			push_error("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			push_error("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var entity_data : Dictionary = node.save()
		entities_data[node.name] = entity_data
	

## Player Data
func save() -> Signal:
	
	# Save Player Data
	update_save_dicts_data()
	var save_file : FileAccess = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var all_data : Dictionary = {"player_data":  player_data, "scene_data" : scene_data, "entities_data" : entities_data}
	var json_string : String = JSON.stringify(all_data, "\t")
	save_file.store_line(json_string)
	
	return get_tree().process_frame

func load_save() -> Signal:
	if not FileAccess.file_exists("user://savegame.save"):
		push_error("Attempt to load nonexistent save.")
		
	var save_file : FileAccess = FileAccess.open("user://savegame.save", FileAccess.READ)
	var text : String = save_file.get_as_text()
	# Creates the helper class to interact with JSON.
	var json : JSON = JSON.new()
	
	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result : Error = json.parse(text)
	if parse_result != OK:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", save_file, " at line ", json.get_error_line())
	
	var data : Variant = json.data
	player_data = data["player_data"]
	scene_data = data["scene_data"]
	entities_data = data["entities_data"]
	
	# Set Player Data
	for i : String in player_data.keys():
		Globals.set(i, player_data[i])
		
	# Set Scene Data
	var scene_handler : Node = get_tree().get_nodes_in_group("SceneHandler")[0]
	scene_handler.curr_scene_path = scene_data["curr_scene_path"]
	
	# Spawn and Set Entities
	# done in respective scenes during initialize()

	return get_tree().process_frame

func _ready() -> void:
	for weapon : String in all_weapons.keys():
		var weapon_data : WeaponData = load("res://Entities/Weapons/%d/%s/%s.tres" % [all_weapons[weapon], weapon, weapon])
		var replace_dict : Dictionary = {"{name}" : weapon_data.display_name, \
										"{special_cost}" : weapon_data.special_cost,
										"{int1}" : weapon_data.int1, \
										"{int2}" : weapon_data.int2, \
										"{int3}" : weapon_data.int3}
										
		
		var updated_desc : String = fill_placeholders(weapon_data.description, replace_dict)
		weapon_data.description = updated_desc
		
		var updated_lore : String = fill_placeholders(weapon_data.lore, replace_dict)
		weapon_data.lore = updated_lore
		
		all_weap_data[weapon] = weapon_data
