extends Node2D

# Place 2 child nodes from JornaPageContent.generate_page() in here
@onready var pages_holder : HBoxContainer = $Pages/HBoxContainer
@onready var left_arrow : TextureButton = $Buttons/HBoxContainer/LeftArrow
@onready var right_arrow : TextureButton = $Buttons/HBoxContainer/RightArrow

var pages : Array
var curr_section : int = 0:
	set(value):
		var clamped : int = clamp(value, 0, Globals.learned_weapons.size() - 2)
		curr_section = clamped
		
signal armory_updated

# === Custom Methods ===========================================================

func update_learned_weapons() -> void:
	for page : JournalPageContent in pages:
		page.queue_free()
	for weap_name : String in Globals.learned_weapons.keys():
		var page : JournalPageContent = JournalPageContent.generate_page()
		page.visible = false
		pages_holder.add_child(page)
		page.insert_content(Globals.learned_weapons[weap_name], weap_name)
		page.equip_button_pressed.connect(_on_equip_button_pressed)
		pages.append(page)
	update_buttons()
	load_curr_pages()

func load_curr_pages() -> void:
	for page_num : int in pages.size():
		if page_num == curr_section or page_num == curr_section + 1:
			pages[page_num].visible = true
		else:
			pages[page_num].visible = false
			
	if curr_section == 0:
		left_arrow.disabled = true
	else:
		left_arrow.disabled = false
	
	if curr_section >= Globals.learned_weapons.size() - 2:
		right_arrow.disabled = true
	else:
		right_arrow.disabled = false

func update_buttons() -> void:
	for page : JournalPageContent in pages:
		if page.file_name in Globals.armory.values():
			page.equip_button.disabled = true
		else:
			page.equip_button.disabled = false

# === Built In =================================================================

func _ready() -> void:
	update_learned_weapons()

func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_left_arrow_pressed() -> void:
	curr_section -= 2
	load_curr_pages()

func _on_right_arrow_pressed() -> void:
	curr_section += 2
	load_curr_pages()

func _on_equip_button_pressed(_rank : int, _file_name : String) -> void:
	Globals.armory[_rank] = _file_name
	update_buttons()
	armory_updated.emit()
