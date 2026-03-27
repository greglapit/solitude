extends Node2DScene

@onready var player : Node2D = $Player
@onready var player_ap : AnimationPlayer = $Player/AnimationPlayer
@onready var king_ap : AnimationPlayer = $King/AnimationPlayer

var encounters : Dictionary = {
	"default" : 5,
	"rare" : 1
}

var test : String = "Testign"

# === Custom Methods ===========================================================
func arrive_sequences() -> void:
	player.hide()
	
	king_ap.play("arrive")
	
	await get_tree().create_timer(2.0).timeout
	
	player_ap.play("arrive")
	
	for child : Node in get_tree().get_nodes_in_group("animated_sprite"):
		var node : AnimatedSprite2D = child
		node.play("default")
		node.set_frame_and_progress(0,0.0)
		
	await player_ap.animation_finished

func initialize() -> void:
	var balloon : Node = DialogueManager.show_dialogue_balloon(load("res://Scenes/KoDEncounter/kod_default.dialogue"), "start")
	balloon.char_spoke.connect(_on_balloon_char_spoke)
	
	await balloon.tree_exited
	
	# If player has cores
	if Globals.inventory.has("core"):
		balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/KoDEncounter/kod_take_core.dialogue"), "start")
		balloon.char_spoke.connect(_on_balloon_char_spoke)
		

func play_increase_memory() -> void:
	var increase_memory_scn : Node = load("res://Scenes/KoDEncounter/Interactions/increase_memory.tscn").instantiate()
	
	var core_stack : ItemStack = Globals.inventory["core"]
	increase_memory_scn.cores_being_used = core_stack.count
	
	add_child(increase_memory_scn)
	
	await increase_memory_scn.tree_exited
	
	Globals.add_item("core", -core_stack.count)
	
func end_encounter() -> void:
	change_scn.emit()

# === Built In =================================================================

func _ready() -> void:
	Globals.add_item("core", 3)
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
