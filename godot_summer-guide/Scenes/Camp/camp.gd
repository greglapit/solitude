extends Node2DScene

@onready var background : AnimatedSprite2D = $Background
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var health_bar : HealthBar = $CanvasLayer/HealthBar
@onready var plus_heal_label : Label = $CanvasLayer/PlusHealLabel
@onready var rest_button : TextureButton = $CanvasLayer/MarginContainer/RestButton
@onready var memory_button : TextureButton = $CanvasLayer/MarginContainer2/MemoryButton

const journal_memory_scn : PackedScene = preload("res://Scenes/UI/StudyJournal/journal_memory.tscn")

const campfire_heal_amt : int = 3

var pausing_input : bool = false

# === Custom Methods ===========================================================


# === Built In =================================================================

func _init() -> void:
	scene_id = Globals.scenes.CAMP

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================


func _on_memory_button_pressed() -> void:
	if pausing_input:
		return
	var journal_memory_node : Node2D = journal_memory_scn.instantiate()
	add_child(journal_memory_node)
	
	pausing_input = true
	memory_button.disabled = true
	background.pause()
	await journal_memory_node.tree_exited
	
	pausing_input = false
	memory_button.disabled = false
	background.play()

func _on_rest_button_pressed() -> void:
	if pausing_input:
		return
	pausing_input = true
	rest_button.disabled = true
	memory_button.disabled = true
	plus_heal_label.text = "+" + str(campfire_heal_amt)
	animation_player.play("plus_health")
	
	Globals.hp += campfire_heal_amt
	health_bar.display_hp(Globals.hp)
	await animation_player.animation_finished
	
	
	change_scn.emit(Globals.scenes.NIGHTTIME, false, false)
