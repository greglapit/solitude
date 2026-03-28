extends Node2D

@onready var memory : Node2D = $CanvasLayer2/Memory
@onready var journal : Node2D = $CanvasLayer2/Journal
@onready var capacity_label : Label = $CanvasLayer2/MarginContainer/CapacityLabel

# === Custom Methods ===========================================================

# === Built In =================================================================

func _ready() -> void:
	memory.armory_updated.connect(_on_memory_armory_updated)
	journal.armory_updated.connect(_on_journal_armory_updated)
	capacity_label.update()
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_memory_armory_updated() -> void:
	journal.update_buttons()
	capacity_label.update()

func _on_journal_armory_updated() -> void:
	memory.update_icons(true)
	capacity_label.update()


func _on_button_pressed() -> void:
	queue_free()
