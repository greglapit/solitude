class_name JackShop
extends CanvasLayer

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
