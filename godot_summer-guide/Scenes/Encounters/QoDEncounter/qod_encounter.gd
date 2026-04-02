extends Node2DScene

@onready var player : Node2D = $Player
@onready var player_ap : AnimationPlayer = $Player/AnimationPlayer
@onready var queen_ap : AnimationPlayer = $QOD/AnimationPlayer

var encounters : Dictionary = {
	"default" : 5,
	"rare" : 1
}

# === Custom Methods ===========================================================
func initialize() -> void:
	var balloon : Node = DialogueManager.show_dialogue_balloon(load("res://Scenes/Encounters/QoDEncounter/qod_default.dialogue"), "start")
	balloon.char_spoke.connect(_on_balloon_char_spoke)
	
	await balloon.tree_exited

func arrive_sequences() -> void:
	player.hide()
	
	queen_ap.play("arrive")
	
	await get_tree().create_timer(1.5).timeout
	
	player_ap.play("arrive")
	
	for child : Node in get_tree().get_nodes_in_group("animated_sprite"):
		var node : AnimatedSprite2D = child
		node.play("default")
		node.set_frame_and_progress(0,0.0)
		
	await player_ap.animation_finished

func show_title() -> void:
	queen_ap.play("show_title")
	await queen_ap.animation_finished

func play_gift_rank() -> void:
	var gift_rank_scn : Node2D = load("res://Scenes/Encounters/QoDEncounter/Interactions/gift_rank.tscn").instantiate()
	
	add_child(gift_rank_scn)
	
	await gift_rank_scn.tree_exited

func end_encounter() -> void:
	change_scn.emit("res://Scenes/Camp/camp.tscn", false, false)

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
		"QOD":
			queen_ap.play("bump")
		_:
			pass
