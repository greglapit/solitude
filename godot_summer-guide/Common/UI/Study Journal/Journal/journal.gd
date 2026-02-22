extends Node2D

@onready var page_location : HBoxContainer = $Control/HBoxContainer

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	var page : JournalPageContent = JournalPageContent.generate_page()
	page_location.add_child(page)
	page.insert_content(10, "10_pirate_weapon")
	
	var page2 : JournalPageContent = JournalPageContent.generate_page()
	page_location.add_child(page2)
	page2.insert_content(10, "10_pirate_weapon")
	
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
