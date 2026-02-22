extends MarginContainer

@onready var weap_name : Label = $VBoxContainer/WeaponName
@onready var second_name : Label = $VBoxContainer/SecondName
@onready var weap_art : TextureRect = $VBoxContainer/WeaponArt
@onready var weap_desc : Label = $VBoxContainer/WeaponDesc
@onready var weap_lore : Label = $VBoxContainer/WeapLore
@onready var equip_button : TextureButton = $VBoxContainer/CenterContainer/EquipButton


# === Custom Methods ===========================================================

func insert_content(rank : String, weapon_name : String) -> void:
	var weapon_data : WeaponData = load("res://Entities/Weapons/%s/%s/%s.tres" % [rank, weapon_name, weapon_name]) 
	
	weap_name.text = weapon_data.display_name
	second_name.text = weapon_data.second_name
	weap_art.texture = weapon_data.display_texture
	weap_desc.text = weapon_data.description
	weap_lore = w


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
