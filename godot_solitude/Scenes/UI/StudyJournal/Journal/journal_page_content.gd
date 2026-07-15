class_name JournalPageContent
extends MarginContainer

@onready var weap_name : Label = $VBoxContainer/WeaponName
@onready var second_name : Label = $VBoxContainer/SecondName
@onready var weap_art : TextureRect = $VBoxContainer/WeaponArt
@onready var weap_desc : Label = $VBoxContainer/WeaponDesc
@onready var weap_lore : Label = $VBoxContainer/WeapLore
@onready var equip_button : TextureButton = $VBoxContainer/CenterContainer/EquipButton
@onready var equip_button_container : CenterContainer = $VBoxContainer/CenterContainer

var rank : int
var file_name : String
const journal_page_content_scn : PackedScene = preload("res://Scenes/UI/StudyJournal/Journal/journal_page_content.tscn")

signal equip_button_pressed(rank : int, f_name : String)



# === Custom Methods ===========================================================
static func generate_page() -> MarginContainer:
	var node : MarginContainer = journal_page_content_scn.instantiate()
	return node
	
func insert_content(_rank : int, _file_name : String) -> void:
	rank = _rank
	file_name = _file_name
	
	var weapon_data : WeaponData = Globals.all_weap_data[_file_name]
	name = weapon_data.display_name + " Page"
	
	weap_name.text = str(_rank) + ": " + weapon_data.display_name
	second_name.text = weapon_data.second_name
	weap_art.texture = weapon_data.display_texture
	weap_desc.text = weapon_data.description
	weap_lore.text = weapon_data.lore
	
	# Base weapons no equip button
	if file_name.contains("base"):
		equip_button_container.visible = false
	else:
		equip_button_container.visible = true


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================


func _on_equip_button_pressed() -> void:
	equip_button_pressed.emit(rank, file_name)
