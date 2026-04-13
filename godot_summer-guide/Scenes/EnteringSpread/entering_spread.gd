extends Node2DScene

@onready var background : AnimatedSprite2D = $Background
@onready var map : Map = $Map
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var boss_battle : bool

func initialize() -> void:
	boss_battle = ProgressTracker.rounds_per_suit == ProgressTracker.player_location["round"]
	if boss_battle:
		# TODO ADD PRE-BOSS => BOSS SCREEN OR JUST BOSS BATTLE
		change_scn.emit(Globals.scenes.BATTLE, false, true)
	else:
		change_scn.emit(Globals.scenes.CHOOSE_ENCOUNTER, false, true)
	background.play("default")

func _on_background_animation_finished() -> void:
	animation_player.play("show_map")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	ProgressTracker.player_location["round"] += 1
	var progress : float = float(ProgressTracker.player_location["round"]) / float(ProgressTracker.rounds_per_suit)
	
	await map.move_player(ProgressTracker.player_location["suit"], progress)
	await get_tree().create_timer(1.0).timeout
	
	
	scene_ready_for_swap.emit()
	
