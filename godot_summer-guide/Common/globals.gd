extends Node

var ranks : Array = ["0","A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Save Dictionaries
var player_data : Dictionary
var scene_data : Dictionary
var entities_data : Dictionary
var progress_data : Dictionary

var hp : int = 20:
	set(value):
		hp = clamp(value, 0, max_hp)
var max_hp : int = 20
var draw_amt : int = 3
var actions : int = 1
var attacks : int = 1
var max_draw : int = 3			# How many items player can have drawn at a time
var max_crits : int = 3

# Convert all keys to int automatically for JSON
var armory : Dictionary = {1 : "1_base_weapon", 2 : "2_base_weapon", 3 : "3_base_weapon"}: 
	set(value):
		# If key is string (JSON)
		if typeof(value.keys()[0]) == TYPE_STRING:
			armory = {}
			for key : String in value.keys():
				var int_key : int = int(key)
				armory[int_key] = value[key]
		else:
			armory = value
var learned_ranks : Array = armory.keys()
var memory_capacity : int = 5
var init_armory_dur : int = 3
var armory_durs : Array # Form = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5] (for each rank)
var inventory : Dictionary		# item.id : item_stack

#region # Weapon Dicts

var learned_weapons : Dictionary = {
	#'1_base_weapon' : 1 , '1_philo_weapon' : 1, '1_seed_weapon' : 1, \
	#'2_base_weapon' : 2, '2_twin_weapon' : 2, '2_glass_weapon' : 2, \
	#'3_base_weapon' : 3, '3_trident_weapon' : 3, '3_prowler_weapon' : 3, \
	#'4_base_weapon' : 4, '4_mirra_weapon' : 4, '4_bastion_weapon' : 4,\
	#'5_base_weapon' : 5, '5_claw_weapon' : 5, '5_maw_weapon' : 5,\
	#'6_base_weapon' : 6, '6_locklash_weapon' : 6, '6_weaver_weapon' : 6,\
	#'7_base_weapon' : 7, '7_vamp_weapon' : 7, '7_severance_weapon' : 7,\
	#'8_base_weapon' : 8, '8_splitter_weapon' : 8, '8_cata_weapon' : 8,\
	#'9_base_weapon' : 9, '9_cloud_weapon' : 9, '9_cmd_weapon' : 9,\
	#'10_base_weapon' : 10, '10_clock_weapon' : 10, '10_pirate_weapon' : 10\
}

## Weapons still available to be given during run. Value is their weight
var available_weapon_pool : Dictionary = {
	#'1_philo_weapon' : 1, '1_seed_weapon' : 1, \
	#'2_twin_weapon' : 1, '2_glass_weapon' : 1, \
	#'3_trident_weapon' : 1, '3_prowler_weapon' : 1, \
	#'4_mirra_weapon' : 1, '4_bastion_weapon' : 1,\
	#'5_claw_weapon' : 1, '5_maw_weapon' : 1,\
	#'6_locklash_weapon' : 1, '6_weaver_weapon' : 1,\
	#'7_vamp_weapon' : 1, '7_severance_weapon' : 1,\
	#'8_splitter_weapon' : 1, '8_cata_weapon' : 1,\
	#'9_cloud_weapon' : 1, '9_cmd_weapon' : 1,\
	#'10_clock_weapon' : 1, '10_pirate_weapon' : 1\
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

#endregion

var all_weap_data : Dictionary 		## file_name : resources. All loaded modified weapon resources
var all_item_data : Dictionary 		## 

var valid_save_scenes : Array = [
	"res://Scenes/Camp/camp.tscn",
]

enum scenes {
	MAIN_MENU,
	START_CUTSCENE,
	TUTORIAL_BATTLE,
	BATTLE,
	KOD,
	QOD,
	CAMP,
	NIGHTTIME,
	ENTERING_SPREAD
}

var scene_paths : Dictionary = {
	scenes.MAIN_MENU : "res://Scenes/MainMenu/main_menu.tscn",
	scenes.START_CUTSCENE : "res://Scenes/StartCutscene/start_cutscene.tscn",
	scenes.TUTORIAL_BATTLE : "res://Scenes/TutorialBattle/tutorial_battle.tscn",
	scenes.BATTLE : "res://Scenes/Battle/battle.tscn",
	scenes.KOD : "res://Scenes/Encounters/KoDEncounter/kod_encounter.tscn",
	scenes.QOD : "res://Scenes/Encounters/QoDEncounter/qod_encounter.tscn",
	scenes.CAMP : "res://Scenes/Camp/camp.tscn",
	scenes.NIGHTTIME : "res://Scenes/Nighttime/nighttime.tscn",
	scenes.ENTERING_SPREAD : "res://Scenes/EnteringSpread/entering_spread.tscn"
}


# ==================================================================================================
# Inventory
#region

func add_item(id : String, amt : int) -> void:
	if !inventory.has(id):
		var new_stack : ItemStack = ItemStack.new()
		new_stack.item = all_item_data[id]
		inventory[id] = new_stack
	
	inventory[id].count += amt
	
	if inventory[id].count <= 0:
		inventory.erase(id)

#endregion

# ==================================================================================================
# Helper Functions
#region
# ==================================================================================================
## Takes dictionary "string" : weight and returns random string based on weight
func weighted_pick_random(dict : Dictionary) -> String:
	var total : int = 0
	
	for weight : int in dict.values():
		total += weight
		
	
	var r : float = randf() * total
	
	var cumulative : int = 0
	for val : String in dict.keys():
		cumulative += dict[val]
		if r < cumulative:
			return val
			
	return ""

func fill_placeholders(template: String, vars: Dictionary) -> String:
	for key : String in vars.keys():
		template = template.replace(key, str(vars[key]))
	return template

## Create generic code-pasteable dict of all serializable vars in script, with additional details
func create_default_save_dict(node : Node) -> String:
	var data : Dictionary = {
		"name" : "name",
		"class_name" : "get_class()",
		"filename" : "get_scene_file_path()",
		"parent" : "get_parent().get_path()",
		"pos_x" : "position.x",
		"pos_y" : "position.y",
		"z_index" : "z_index",
	}
	
	# Loop through all script variables
	var script : GDScript = node.get_script()
	if !script:
		return JSON.stringify(data, "\t")
	for prop : Dictionary in script.get_script_property_list():
		
		# Skip functions and constants; keep only variables
		if prop["type"] == TYPE_CALLABLE or prop["type"] == TYPE_OBJECT:
			continue
			
		# Remove storing Objects because they can't be serialized in JSON.
		if prop["type"] == TYPE_DICTIONARY:
			var container : Dictionary = node.get(prop["name"])
			if container.values().is_empty() or container.values()[0] is Object:
				continue
				
		# Remove storing Objects because they can't be serialized in JSON.
		if prop["type"] == TYPE_ARRAY:
			var container : Array = node.get(prop["name"])
			if container.is_empty() or container[0] is Object:
				continue
				
				
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			data[prop["name"]] = prop["name"]
	
	var json_string : String = JSON.stringify(data, "\t")
	var regex : RegEx = RegEx.new()
	regex.compile(':\\s*"([^"]*)"')
	json_string = regex.sub(json_string, ': $1', true)

	
	return json_string

## Overwrite all values in dictionary "var : value" to node.
## Rekeys serialized json objects in dict.values() to their nodes if dict contains dict["rekeyed_to_name"] = true
func assign_vars_from_dict(node : Node, dict : Dictionary) -> void:
	var node_props : Array = node.get_script().get_script_property_list()
	var node_prop_names : Array = node_props.map(func(k : Variant) -> String: return k.name)
	for key : Variant in dict.keys():
		if key not in node_prop_names:
			continue
		
		var val_type : int = typeof(dict[key])
		
		match val_type:
			TYPE_DICTIONARY:
				if dict[key].has("rekeyed_to_name") and dict[key]["rekeyed_to_name"] == true:
					dict[key].erase("rekeyed_to_name")
					rekey_names_to_objects(dict[key], node)
			_:
				pass
		
		node.set(key, dict[key])


func rekey_objects_to_names(dict : Dictionary) -> void:
	for val : Node in dict.keys():
		dict[val.name] = dict[val]
		dict.erase(val)
	dict["rekeyed_to_name"] = true

func rekey_names_to_objects(dict : Dictionary, node : Node) -> void:
	for val : String in dict.keys():
		var node_match : Node = node.get_tree().get_root().find_child(val, true, false)
		
		if !node_match:
			push_error("Node %s saved but not found in tree after initializing" % [val])
		else:
			dict[node_match] = dict[val]
			dict.erase(val)
#endregion
# ==================================================================================================
# Save/Loading
#region
## Updates player, scene, and entity data
func update_save_dicts_data() -> void:
	player_data.clear()
	scene_data.clear()
	entities_data.clear()
	progress_data.clear()
	
	
	
	# Player
	player_data = {
		"hp" = hp,
		"max_hp" = max_hp,
		"draw_amt" = draw_amt,
		"actions" = actions,
		"attacks" = attacks,
		"max_draw" = max_draw,
		"max_crits" = max_crits,
		"armory" = armory,
		"learned_ranks" = armory.keys(),
		"learned_weapons" = learned_weapons,
		"available_weapon_pool" = available_weapon_pool,
		"memory_capacity" = memory_capacity,
		"armory_durs" = armory_durs,
	}
	
	var JSON_inventory : Dictionary
	for item_id : String in inventory.keys():
		var item_stack_data : ItemStack = inventory[item_id]
		var dict : Dictionary = item_stack_data.save()
		JSON_inventory[item_id + "_item_stack"] = dict
		
	player_data["inventory"] = JSON_inventory
	
	# Scene
	var scene_handler : Node = get_tree().get_nodes_in_group("SceneHandler")[0]
	var curr_scene_node : Node = scene_handler.curr_scene
			# Check the node has a save function.
	if !curr_scene_node.has_method("save"):
		scene_data["log"] = "No data to be saved :O"
	else:
		# Call the node's save function.
		scene_data = curr_scene_node.save()
	scene_data["curr_scene_path"] = scene_handler.curr_scene_path
	scene_data["seed"] = rng.seed
	
	
	# Entities
	var save_entities : Array[Node] = get_tree().get_nodes_in_group("persist")
	for node : Node in save_entities:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			push_error("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		var entity_data : Dictionary
		if !node.has_method("save"):
			push_error("persistent node '%s' is missing a save() function, skipped" % node.name)
		else:
		# Call the node's save function.
			entity_data = node.save()
		entities_data[node.name] = entity_data
		
	progress_data = ProgressTracker.save()
	

## Player Data
func save() -> Signal:
	
	# Save Player Data
	update_save_dicts_data()
	var save_file : FileAccess = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var all_data : Dictionary = {
		"player_data":  player_data, 
		"scene_data" : scene_data, 
		"entities_data" : entities_data, 
		"progress_data" : progress_data
	}
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
	progress_data = data["progress_data"]
	
	# Set Player Data
	for i : String in player_data.keys():
		match i:
			"inventory":
				for key : String in player_data["inventory"]:
					var dict : Dictionary = player_data["inventory"][key]
					var new_stack : ItemStack = ItemStack.new()
					new_stack.item = all_item_data[dict.item_id]
					new_stack.count = dict.count
					inventory[dict.item_id] = new_stack
			"available_weapon_pool":
				for key : String in available_weapon_pool:
					if key not in player_data["available_weapon_pool"]:
						available_weapon_pool.erase(key)
			_:
				Globals.set(i, player_data[i])
		
		
		
	# Set Scene Transfer
	var scene_handler : Node = get_tree().get_nodes_in_group("SceneHandler")[0]
	scene_handler.curr_scene_path = scene_data["curr_scene_path"]
	seed(scene_data["seed"])
	
	# Spawn and Set Entities
	# done in respective scenes during initialize()

	# Progress
	ProgressTracker.load_save(progress_data)

	return get_tree().process_frame

func delete_save() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		push_error("Attempt to delete nonexistent save.")
		return
		
	var error : Error = DirAccess.remove_absolute("user://savegame.save")
	if error != OK:
		push_error("Failed to delete save file. Error code: ", error)
		return

func load_all_resources() -> void:
	
	# WEAPONS
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
		
	# ITEMS
	var folder_path : String = "res://Entities/Items/Resources/"
	var files_in_dir : PackedStringArray = DirAccess.get_files_at(folder_path)
	for file_name : String in files_in_dir:
		var item_data : Item = load(folder_path + "/" + file_name)
		all_item_data[item_data.id] = item_data

#endregion

func intitialize_weapon_pool() -> void:
	var armory_keys : Array = armory.keys()
	armory_keys.sort()
	if !armory.is_empty() and armory_keys.size() <= 3:
		GiftRank.add_weapon_pool(range(armory_keys[0], armory_keys.back() + 1))
	else:
		push_error("Initializing with too many items in armory")

func initialize_armory_durs() -> void:
	armory_durs.clear()
	armory_durs.resize(10)
	armory_durs.fill(init_armory_dur)
	
# ==============================================================================
func _ready() -> void:
	load_all_resources() # TODO: Maybe DELETE? Handled in scenehandler
	rng.randomize()
	
	intitialize_weapon_pool()
	initialize_armory_durs()
