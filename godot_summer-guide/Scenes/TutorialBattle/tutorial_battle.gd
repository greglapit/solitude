class_name TutorialBattle
extends Battle

# === Custom Methods ===========================================================

func initialize() -> void:
	#var balloon : Node = DialogueManager.show_dialogue_balloon(load("res://Scenes/Encounters/KoDEncounter/kod_default.dialogue"), "start")
	pass

func end_battle() -> void:
	player.play("base_dazed")
	await get_tree().create_timer(4.0).timeout
	change_scn.emit(Globals.scenes.CAMP, false, false)

# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
