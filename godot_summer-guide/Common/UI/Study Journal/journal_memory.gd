extends Node2D

@onready var memory : Node2D = $CanvasLayer/Memory
@onready var journal : Node2D = $CanvasLayer/Journal

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	memory.armory_updated.connect(_on_memory_armory_updated)
	journal.armory_updated.connect(_on_journal_armory_updated)
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_memory_armory_updated() -> void:
	journal.update_buttons()

func _on_journal_armory_updated() -> void:
	memory.update_icons()
