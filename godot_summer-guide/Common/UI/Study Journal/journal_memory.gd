extends Node2D

@onready var memory : Node2D = $CanvasLayer2/Memory
@onready var journal : Node2D = $CanvasLayer2/Journal
@onready var capacity_label : Label = $CanvasLayer2/MarginContainer/CapacityLabel

# === Custom Methods ===========================================================

func update_capacity_label() -> void:
	var non_base_weapons : Array = Globals.armory.values().filter(func(e : String) -> bool: return !e.contains("base"))
	
	capacity_label.text = "Memory Capacity: %d/%d" % [non_base_weapons.size(), Globals.memory_capacity]

# === Built In =================================================================

func _ready() -> void:
	memory.armory_updated.connect(_on_memory_armory_updated)
	journal.armory_updated.connect(_on_journal_armory_updated)
	update_capacity_label()
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_memory_armory_updated() -> void:
	journal.update_buttons()
	update_capacity_label()

func _on_journal_armory_updated() -> void:
	memory.update_icons(true)
	update_capacity_label()
