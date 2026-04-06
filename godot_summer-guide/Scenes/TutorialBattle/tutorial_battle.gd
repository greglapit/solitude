class_name TutorialBattle
extends Battle

# === Custom Methods ===========================================================

func initialize() -> void:
	var balloon : Node = DialogueManager.show_dialogue_balloon(load("res://Scenes/Encounters/KoDEncounter/kod_default.dialogue"), "start")
	

# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
