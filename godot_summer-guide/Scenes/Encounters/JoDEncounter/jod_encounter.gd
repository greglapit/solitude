extends Node2DScene

@onready var player : Node2D = $Player
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var player_ap : AnimationPlayer = $Player/AnimationPlayer
@onready var jod_ap : AnimationPlayer = $JOD/AnimationPlayer


# === Custom Methods ===========================================================
func initialize() -> void:
	await get_tree().create_timer(3.0).timeout
	animation_player.play("arrive_sequence")
	await animation_player.animation_finished

func light_fluctuation(lights : Array) -> void:
	var time_between_fluct : float = 1.0
	var light_fluct_amt : float = .1
	while true:
		for light : PointLight2D in lights:
			light.scale += Vector2.ONE * light_fluct_amt
			await get_tree().create_timer(.2).timeout
		await get_tree().create_timer(time_between_fluct).timeout
		
		for light : PointLight2D in lights:
			light.scale -= Vector2.ONE * light_fluct_amt
			await get_tree().create_timer(.2).timeout
		await get_tree().create_timer(time_between_fluct).timeout
		

func end_encounter() -> void:
	change_scn.emit(Globals.scenes.CAMP, false, false)
	
# === Built In =================================================================

func _ready() -> void:
	var lights : Array = get_tree().get_nodes_in_group("light")
	light_fluctuation(lights)

func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_balloon_char_spoke(_char : String) -> void:
	match _char:
		#"Fool":
			#player_ap.play("bump")
		#"JOD":
			#jod_ap.play("bump")
		_:
			pass
