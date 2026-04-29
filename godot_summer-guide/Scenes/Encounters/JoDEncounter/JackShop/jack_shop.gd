class_name JackShop
extends CanvasLayer

@onready var item_list1 : ItemList = $JackShop/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/ItemList
@onready var item_list2 : ItemList = $JackShop/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/ItemList
@onready var item_list3 : ItemList = $JackShop/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/VBoxContainer/ItemList
@onready var item_list4 : ItemList = $JackShop/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/VBoxContainer/ItemList
@onready var animation_player : AnimationPlayer = $AnimationPlayer

const jack_shop_scene : PackedScene = preload("res://Scenes/Encounters/JoDEncounter/jack_shop.tscn")

# === Custom Methods ===========================================================

static func generate_shop() -> JackShop:
	var shop_node : JackShop = jack_shop_scene.instantiate()
	return shop_node


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
