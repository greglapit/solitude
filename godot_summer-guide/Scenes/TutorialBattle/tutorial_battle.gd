class_name TutorialBattle
extends Battle

@onready var tutorial_ap : AnimationPlayer = $AnimationPlayer

# === Custom Methods ===========================================================

func initialize() -> void:
	var balloon : Balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/TutorialBattle/tutorial.dialogue"), "start")
	await balloon.char_spoke
	balloon.dialogue_label.started_typing.connect(_on_started_typing)
	balloon.dialogue_label.finished_typing.connect(_on_finished_typing)
	
	
	await balloon.tree_exited
	spawn_enemy(3)
	pause_input = false

func end_battle() -> void:
	player.play("base_dazed")
	await get_tree().create_timer(3.0).timeout
	change_scn.emit(Globals.scenes.CAMP, false, false)

# === Built In =================================================================

func _ready() -> void:
	super()
	#weapons_display.hide()
	#attack_buttons_ui.hide()
	#turn_clock.hide()
	#health_bar.hide()
	#tatter_count.hide()
	#crit_button.hide()
	#hands_label.hide()
	
func _unhandled_input(event: InputEvent) -> void:
	super(event)

# === Signals ==================================================================

func _on_started_typing() -> void:
	weapons_display.play("joker_talking")
	
func _on_finished_typing() -> void:
	weapons_display.play("joker_idle")
