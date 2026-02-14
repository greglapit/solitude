extends Node2D

var chain_line_scn : PackedScene
@export var chain_line_texture : String
var chain_lines : Array[Line2D]

# === Custom Methods ===========================================================

func add_chain(point1 : Vector2, point2 : Vector2) -> Line2D:
	var chain_line : Line2D = chain_line_scn.instantiate()
	chain_line.add_point(point2)
	chain_line.add_point(point1)
	chain_line.texture = load("res://Entities/Weapons/ArtWeaponEffects/" + chain_line_texture)
	add_child(chain_line)
	chain_lines.append(chain_line)
	return chain_line
	
func remove_chains() -> void:
	for chain : Line2D in chain_lines:
		chain.queue_free()
	chain_lines.clear()


# === Built In =================================================================

func _ready() -> void:
	chain_line_scn = load("res://Entities/Weapons/ArtWeaponEffects/chain_line.tscn")
	
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
