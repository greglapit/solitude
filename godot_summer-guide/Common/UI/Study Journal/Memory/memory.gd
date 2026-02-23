extends Node2D

var texture_rects : Array

var icons : Array
var icon_opacity : Color = Color(1.0, 1.0, 1.0, 0.2)
var weap_textures : Dictionary 		# weap_name : texture

signal armory_updated

# === Custom Methods ===========================================================

func load_texture_rects() -> void:
	texture_rects = get_tree().get_nodes_in_group("icon_texture_rects")
	for rect : TextureRect in texture_rects:
		rect.gui_input.connect(_on_rect_gui_input.bind(rect))

func load_icons() -> void:
	for i : int in range(1,11):
		icons.append(load("res://Common/UI/Study Journal/Memory/Art/Icons/%d_icon.png" % [i]))

func update_learned_weapons() -> void:
	weap_textures.clear()
	for weap_name : String in Globals.learned_weapons.keys():
		var weap_data : WeaponData = Globals.all_weap_data[weap_name]
		weap_textures[weap_name] = weap_data.display_texture
	update_icons()
	
func update_icons() -> void:
	for rect : TextureRect in texture_rects:
		var rank : int = int(rect.name.replace("TextureRect", ""))
		if rank in Globals.armory.keys():
			var weap_name : String = Globals.armory[rank]
			rect.texture = weap_textures[weap_name]
			rect.modulate = Color(1.0, 1.0, 1.0)
			rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		else:
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			rect.texture = icons[rank - 1]
			rect.modulate = icon_opacity


# === Built In =================================================================

func _ready() -> void:
	load_texture_rects()
	load_icons()
	update_learned_weapons()
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_rect_gui_input(event : InputEvent, rect : TextureRect) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var rank : int = int(rect.name.replace("TextureRect", ""))
			if rank in Globals.armory.keys():
				Globals.armory.erase(rank)
				update_icons()
				armory_updated.emit()
