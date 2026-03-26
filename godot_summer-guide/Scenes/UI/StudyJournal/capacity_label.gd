extends Label

func update() -> void:
	var non_base_weapons : Array = Globals.armory.values().filter(func(e : String) -> bool: return !e.contains("base"))
	
	text = "Memory Capacity: %d/%d" % [non_base_weapons.size(), Globals.memory_capacity]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()
