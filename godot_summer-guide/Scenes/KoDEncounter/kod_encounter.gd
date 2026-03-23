extends Node2DScene

@onready var player : Node2D = $Player
@onready var player_ap : AnimationPlayer = $Player/AnimationPlayer
@onready var king_ap : AnimationPlayer = $King/AnimationPlayer
@onready var dialogue_area : Control = $CanvasLayer/DialogueArea

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	
	player.visible = false
	
	king_ap.play("arrive")
	
	await get_tree().create_timer(2.0).timeout
	
	player_ap.play("arrive")
	
	for child : Node in get_tree().get_nodes_in_group("animated_sprite"):
		var node : AnimatedSprite2D = child
		node.play("default")
		node.set_frame_and_progress(0,0.0)
	
	await player_ap.animation_finished
	
	var text_box : Node = DialogueManager.show_dialogue_balloon(load("res://Scenes/KoDEncounter/kod.dialogue"), "start")
	text_box.reparent(dialogue_area)

func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
