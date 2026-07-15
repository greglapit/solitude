class_name GiftRank
extends Node2D

@onready var weapon_art1 : TextureRect = $CanvasLayer/VBoxContainer/HBoxContainer/WeaponArt1
@onready var weapon_art2 : TextureRect = $CanvasLayer/VBoxContainer/HBoxContainer/WeaponArt2
@onready var weapon_art3 : TextureRect = $CanvasLayer/VBoxContainer/HBoxContainer/WeaponArt3
@onready var label : Label = $CanvasLayer/VBoxContainer/Label
@onready var animation_player : AnimationPlayer = $AnimationPlayer

## Must be only 3 weapons
var ranks_to_unlock : Array = range(ProgressTracker.unlocked_rank + 1, ProgressTracker.unlocked_rank + 2):
	set(value):
		ranks_to_unlock = value.slice(0,3)
var event_completed : bool = false
var pause_input : bool = false

# === Custom Methods ===========================================================
static func add_weapon_pool(new_ranks : Array) -> void:
	
	for new_rank : int in new_ranks:
		# Add weapons to available weapons to be given to player
		for weapon : String in Globals.all_weapons.keys():
			if weapon.contains("base"):
				continue
			if Globals.all_weapons[weapon] == new_rank:
				Globals.available_weapon_pool[weapon] = new_rank
		
		# Give player base weapon
		Globals.learned_weapons[str(new_rank) + "_base_weapon"] = new_rank
		ProgressTracker.unlocked_rank = new_rank
	
	return

# === Built In =================================================================

func _ready() -> void:
	pause_input = true
	if ranks_to_unlock.back() > 10:
		push_error("Attempting to unlock rank %d" % [ranks_to_unlock.back()])
		return
	
	match ranks_to_unlock.size():
		1:
			label.text = "Unlocked Rank %d Weapons" % [ranks_to_unlock[0]]
		2:
			label.text = "Unlocked Rank %d & %d Weapons" % [ranks_to_unlock[0], ranks_to_unlock.back()]
		3:
			label.text = "Unlocked Rank %d - %d Weapons" % [ranks_to_unlock[0], ranks_to_unlock.back()]
	
	for i : int in ranks_to_unlock.size():
		var var_name : String = "WeaponArt" + str(i + 1)
		var rank_to_unlock : int = ranks_to_unlock[i]
		var weapon_art_node : TextureRect = find_child(var_name)
		weapon_art_node.texture = load("res://Scenes/Encounters/QoDEncounter/Interactions/RankUnlocks/rank%d.png" % [rank_to_unlock])
		weapon_art_node.show()
	
	animation_player.play("show")
	
	await animation_player.animation_finished
	add_weapon_pool(ranks_to_unlock)
	pause_input = false
	
func _input(_event: InputEvent) -> void:
	if pause_input:
		return
	if _event.is_pressed():
		if event_completed:
			animation_player.play("hide")
		get_viewport().set_input_as_handled()
		

# === Signals ==================================================================


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"show":
			event_completed = true
		"hide":
			queue_free()
