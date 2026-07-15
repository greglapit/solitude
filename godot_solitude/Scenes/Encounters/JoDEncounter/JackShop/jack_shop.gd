class_name JackShop
extends CanvasLayer

@onready var item_list1 : ItemList = $JackShop/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/ItemList
@onready var item_list2 : ItemList = $JackShop/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer2/PanelContainer/VBoxContainer/ItemList
@onready var item_list3 : ItemList = $JackShop/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/PanelContainer/VBoxContainer/ItemList
@onready var item_list4 : ItemList = $JackShop/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/PanelContainer/VBoxContainer/ItemList
@onready var animation_player : AnimationPlayer = $AnimationPlayer

const jack_shop_scene : PackedScene = preload("res://Scenes/Encounters/JoDEncounter/JackShop/jack_shop.tscn")

var pause_input : bool = true
var consumable_amt : Array = range(1,4)

# === Custom Methods ===========================================================

static func generate_shop() -> JackShop:
	var shop_node : JackShop = jack_shop_scene.instantiate()
	return shop_node
	  
## Returns array of concentrates and suppressants that the player is allowed to take
func get_valid_pills() -> Array:
	var conc_max : int = Globals.conc_max
	var valid_pills : Array
	
	var pill_counts : Array = Globals.get_pill_counts()
	var concentrate_counts : Array = pill_counts[0]
	var suppressant_counts : Array = pill_counts[1]
	
	for rank : int in concentrate_counts.size():
		var total : int = concentrate_counts[rank] - suppressant_counts[rank]
		
		# Add concentrates to array less than conc_max
		if total < conc_max:
			valid_pills.append("concentrate" + str(rank))
		# Add suppressants to array if total > 0
		if total > 0:
			valid_pills.append("suppressant" + str(rank))
		
	return valid_pills

func generate_shop_items() -> Array:
	var shop_items : Array			## [consumables_arr, upgrades_arr, card_eff_arr, special_arr]
	var consumables_arr : Array
	var upgrades_arr : Array
	var card_eff_arr : Array
	var special_arr : Array
	
	
	
	shop_items = [consumables_arr, upgrades_arr, card_eff_arr, special_arr]
	return shop_items
	
# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_exit_button_pressed() -> void:
	if pause_input:
		return
	animation_player.queue("despawn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"spawn":
			pause_input = false
		"despawn":
			queue_free()
