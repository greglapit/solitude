extends Node2DScene

@onready var player : Node2D = $Player
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var player_ap : AnimationPlayer = $Player/AnimationPlayer
@onready var jod_ap : AnimationPlayer = $JOD/AnimationPlayer


# === Custom Methods ===========================================================
func initialize() -> void:
	await get_tree().create_timer(3.0).timeout
	var balloon : Balloon = DialogueManager.show_dialogue_balloon(load("res://Scenes/Encounters/JoDEncounter/jod_default.dialogue"), "start")
	balloon.char_spoke.connect(_on_balloon_char_spoke)
	await balloon.tree_exited
	
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

func play(anim : String, target : String = "") -> void:
	var ap : AnimationPlayer
	match target:
		"jod":
			ap = jod_ap
		"fool":
			ap = player_ap
		_:
			ap = animation_player
	if ap.is_playing():
		var curr_anim : Animation = animation_player.get_animation(animation_player.current_animation)
		if curr_anim and curr_anim.loop_mode == Animation.LOOP_NONE:
			await ap.animation_finished
	ap.play(anim)
	await ap.animation_finished

func show_shop() -> void:
	var shop : JackShop = JackShop.generate_shop()
	add_child(shop)
	await shop.tree_exited

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
		"Fool":
			player_ap.play("bump")
		"JOD":
			pass
			#jod_ap.play("bump")
		_:
			pass
