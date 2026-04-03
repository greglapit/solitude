extends Node2DScene

@onready var weapon_art : TextureRect = $CanvasLayer/VBoxContainer/WeaponArt
@onready var label : Label = $CanvasLayer/VBoxContainer/Label
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var event_completed : bool = false
# === Custom Methods ===========================================================
func adjust_weapon_pool(new_rank : int) -> void:
	
	# Add weapons to available weapons to be given to player
	for weapon : String in Globals.all_weapons.keys():
		if weapon.contains("base"):
			continue
		if Globals.all_weapons[weapon] == new_rank:
			Globals.available_weapon_pool[weapon] = new_rank
	
	# Give player base weapon
	Globals.learned_weapons[str(new_rank) + "_base_weapon"] = new_rank
	
	

# === Built In =================================================================

func _ready() -> void:
	var rank_to_unlock : int = ProgressTracker.unlocked_rank + 1
	
	label.text = "Unlocked Rank %d Weapons" % [rank_to_unlock]
	weapon_art.texture = load("res://Scenes/Encounters/QoDEncounter/Interactions/RankUnlocks/rank%d.png" % [rank_to_unlock])
	
	
	animation_player.play("show")
	
	await animation_player.animation_finished
	adjust_weapon_pool(rank_to_unlock)
	
func _input(_event: InputEvent) -> void:
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
