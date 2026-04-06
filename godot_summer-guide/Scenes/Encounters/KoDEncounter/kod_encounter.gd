extends Node2DScene

@onready var player : Node2D = $Player
@onready var player_ap : AnimationPlayer = $Player/AnimationPlayer
@onready var king_ap : AnimationPlayer = $KOD/AnimationPlayer


# === Custom Methods ===========================================================
func initialize() -> void:
	var balloon : Node = DialogueManager.show_dialogue_balloon(load("res://Scenes/Encounters/KoDEncounter/kod_default.dialogue"), "start")
	balloon.char_spoke.connect(_on_balloon_char_spoke)
	
	await balloon.tree_exited
	
	# If player has cores
	if Globals.inventory.has("core"):
		balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/Encounters/KoDEncounter/kod_take_core.dialogue"), "start")
		balloon.char_spoke.connect(_on_balloon_char_spoke)
		await balloon.tree_exited
	
	balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/Encounters/KoDEncounter/kod_end_encounter.dialogue"), "start")
	balloon.char_spoke.connect(_on_balloon_char_spoke)

func arrive_sequences() -> void:
	player.hide()
	
	king_ap.play("arrive")
	
	await get_tree().create_timer(1.5).timeout
	
	player_ap.play("arrive")
	
	for child : Node in get_tree().get_nodes_in_group("animated_sprite"):
		var node : AnimatedSprite2D = child
		node.play("default")
		node.set_frame_and_progress(0,0.0)
		
	await player_ap.animation_finished

func show_title() -> void:
	king_ap.play("show_title")
	await king_ap.animation_finished


func play_gift_weapon() -> void:
	var gift_weapon_scn : Node2D = load("res://Scenes/Encounters/KoDEncounter/Interactions/gift_weapon.tscn").instantiate()
	
	add_child(gift_weapon_scn)
	
	await gift_weapon_scn.tree_exited


func play_increase_memory() -> void:
	var increase_memory_scn : Node2D = load("res://Scenes/Encounters/KoDEncounter/Interactions/increase_memory.tscn").instantiate()
	
	add_child(increase_memory_scn)
	
	await increase_memory_scn.tree_exited
	
	
func end_encounter() -> void:
	change_scn.emit(Globals.scenes.CAMP, false, false)

# === Built In =================================================================

func _ready() -> void:
	pass

func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_balloon_char_spoke(_char : String) -> void:
	match _char:
		"Fool":
			player_ap.play("bump")
		"KOD":
			king_ap.play("bump")
		_:
			pass
