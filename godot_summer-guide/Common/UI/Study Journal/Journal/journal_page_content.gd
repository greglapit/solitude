class_name JournalPageContent
extends MarginContainer

@onready var weap_name : Label = $VBoxContainer/WeaponName
@onready var second_name : Label = $VBoxContainer/SecondName
@onready var weap_art : TextureRect = $VBoxContainer/WeaponArt
@onready var weap_desc : Label = $VBoxContainer/WeaponDesc
@onready var weap_lore : Label = $VBoxContainer/WeapLore
@onready var equip_button : TextureButton = $VBoxContainer/CenterContainer/EquipButton

const journal_page_content_scn : PackedScene = preload("res://Common/UI/Study Journal/Journal/journal_page_content.tscn")

static func generate_page() -> MarginContainer:
	var node : MarginContainer = journal_page_content_scn.instantiate()
	return node

# === Custom Methods ===========================================================

func insert_content(rank : int, weapon_name : String) -> void:
	var weapon_data : WeaponData = Globals.all_weap_data[weapon_name]
	name = weapon_data.display_name + " Page"
	
	weap_name.text = str(rank) + ": " + weapon_data.display_name
	second_name.text = weapon_data.second_name
	weap_art.texture = weapon_data.display_texture
	weap_desc.text = weapon_data.description
	weap_lore.text = weapon_data.lore


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
