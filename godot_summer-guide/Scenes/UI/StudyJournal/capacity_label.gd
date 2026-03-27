extends Label

var display_current_stress : bool = true

func update() -> void:
	var non_base_weapons : Array = Globals.armory.values().filter(func(e : String) -> bool: return !e.contains("base"))
	
	if display_current_stress:
		text = "Memory Capacity: %d/%d" % [non_base_weapons.size(), Globals.memory_capacity]
	else:
		text = "Memory Capacity: %d" % [Globals.memory_capacity]
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()
