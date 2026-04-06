extends Node2D

@onready var weapon_name : Label = $CanvasLayer/VBoxContainer/WeaponName
@onready var rank_label : Label = $CanvasLayer/VBoxContainer/Rank
@onready var weapon_art : TextureRect = $CanvasLayer/VBoxContainer/WeaponArt
@onready var animation_player : AnimationPlayer = $AnimationPlayer


## Used internally
var weapon : String
var event_completed : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon = Globals.weighted_pick_random(Globals.available_weapon_pool)
	
	var weapon_data : WeaponData = Globals.all_weap_data[weapon]
	
	weapon_name.text = weapon_data.display_name
	rank_label.text = "Rank %d weapon" % [weapon_data.rank]
	weapon_art.texture = weapon_data.display_texture
	
	animation_player.play("show")
	
	Globals.learned_weapons[weapon_data.file_name] = weapon_data.rank
	Globals.available_weapon_pool.erase(weapon_data.file_name)

func _unhandled_input(_event: InputEvent) -> void:
	if _event.is_pressed():
		if event_completed:
			animation_player.play("hide")
		get_viewport().set_input_as_handled()
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"show":
			event_completed = true
		"hide":
			queue_free()
