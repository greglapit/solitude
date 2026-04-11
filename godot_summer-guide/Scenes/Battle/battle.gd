class_name Battle
extends Node2DScene

@onready var firework_particle : GPUParticles2D = $FireworkGPUParticles2D
@onready var tatters_particle : GPUParticles2D = $TattersGPUParticles2D			#DEPRECIATED

@onready var player : Player = $Player
@onready var weapons_display : WeaponDisplay = $UI/WeaponDisplay
@onready var health_bar : PanelContainer = $UI/HealthBar
@onready var tatter_count : Control = $UI/TatterCount
@onready var tatter_count_label : Label = $UI/TatterCount/MarginContainer/PanelContainer/HBoxContainer/TatterLabel
@onready var chain_button : TextureButton = $UI/AttackButtons/MarginContainer/VBoxContainer/PanelContainer2/ChainButton
@onready var attack_button : TextureButton = $UI/AttackButtons/MarginContainer/VBoxContainer/PanelContainer/AttackButton
@onready var attack_buttons_ui : PanelContainer = $UI/AttackButtons
@onready var crit_button : TextureButton = $UI/CritButton
@onready var turn_clock : TurnClock = $UI/TurnClock
@onready var hands_label : Label = $UI/Hands/Label
@onready var spam_timer : Timer = $SpamTimer
@onready var camera : Camera2D = $BattleCamera2D
@onready var armory_position : Vector2 = $ArmoryPosition.position
@onready var enemy_target_pos : Vector2 = $EnemyTargetPosition.position
@onready var enemy_positions : Array[Vector2] = [enemy_target_pos, enemy_target_pos - Vector2(35,10), enemy_target_pos - Vector2(-30, 20), \
										Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
										
# Used internally
var mini_equipped : MiniCard							# Current card player has equipped
var curr_weapon : Weapon							# String name of player weapon
var player_weapons : Dictionary						## Rank : Weapon
var enemies : Array
var hp : int = Globals.hp:
	set(value):
		Globals.hp = value
		hp = value
var attacks : int = Globals.attacks					# Attacks player has left
var actions : int = Globals.actions					# Actions player has left (draw, cut, socket)
var crits_stored : int = 0							# Number of crits stored
var drawing : bool = false							# Turned on when drawing started, off when it ends
var chaining : bool = false							# Turned on when chain attack is occuring
var pausing_weapons : Array[Weapon]					# Weapon pausing chaining for effects to take place

var combat_data : Dictionary = {
	"hp_delta" = 0,
	"durability_delta" = 0,
	"attacks" = 0
	}
	
var pause_input : bool = true:					# Stops minicard/attack inputs when drawing or attacking
	set(value):
		pause_input_update.emit(value)
		pause_input = value
var turn_order_flipped : bool = false:
	set(value):
		turn_order_flipped = value
		update_turn_clock()

signal pause_input_update(val : bool)


# Presets
var curr_round : int = 1
var max_rounds : int = 5

# DEV TOOLS
var crit_infinite : bool = false

# === Custom Methods ===========================================================
# General
#-------------------------------------------------------------------------------
func initialize() -> void:
	weapons_display.animation_player.play("joker_show")
	spawn_enemy(3)
	await weapons_display.animation_player.animation_finished
	pause_input = false

func end_round() -> void:
	curr_round += 1
	
	if curr_round > max_rounds:
		end_battle()
		return
	
	hands_label.text = "Hands: %d/%d" % [curr_round, max_rounds]
	spawn_enemy(3)
	
func end_battle() -> void:
	player.play("base_bow")
	await player.anim_finished
	firework_particle.emitting = true
	await get_tree().create_timer(4.0).timeout
	change_scn.emit(Globals.scenes.CAMP, false, false)
	
# Depreciated save code
#region
# DEPRECIATED. No longer allowing saving during battle
#func save() -> Dictionary:
	#var data : Dictionary = {
		#"actions": actions,
		#"combat_data": combat_data,
		#"crits_stored": crits_stored,
		#"filename": get_scene_file_path(),
		#"parent": get_parent().get_path(),
		#"turn_order_flipped": turn_order_flipped,
	#}
#
	#return data
#
#func initialize() -> void:
	## player preparing anim add here maybe
	#
	## Default load if no save file
	#if Globals.entities_data.is_empty() or !Globals.scene_data["curr_scene_path"] == scene_file_path:
		#await spawn_enemy(3)
		#pause_input = false
		#return
	#
	## Load saved battle data
	#GlobalsUtil.assign_vars_from_dict(self, Globals.scene_data)
	#
	## Load Entites: enemies, weapons, minicards
	##region
	#var entites_data : Array = Globals.entities_data.values()
	#
	## Mini MiniCard
	#var minis_group : Array = entites_data.filter(func(e : Dictionary) -> bool: return e["class_name"] == "MiniCard")
	#for i : int in range(minis_group.size()):
		#spawn_card(minis_group[i])
	#
	#align_mini_cards()
	#
	## Enemies
	#var enemy_group : Array = entites_data.filter(func(e : Dictionary) -> bool: return e.class_name == "Enemy")
	#enemy_group.sort_custom(func(a : Dictionary, b : Dictionary) -> bool:
		#return a.z_index > b.z_index)
	#for i : int in range(enemy_group.size()):
		#await spawn_enemy(1, enemy_group[i])
	#
	## Weapons
	#var weapons_group : Array = entites_data.filter(func(e : Dictionary) -> bool: return e["class_name"] == "Weapon")
	## waits for load_armory()
	#while player_weapons.size() != Globals.armory.size():
		#await get_tree().process_frame
	#
	#for i : int in range(weapons_group.size()):
		#var weapon_data : Dictionary = weapons_group[i]
		#var rank : int = weapon_data.rank
		#GlobalsUtil.assign_vars_from_dict(player_weapons[rank], weapon_data)
		#player_weapons[rank].initialize()
		
	#pause_input = false

#endregion

## Loads all player weapons into scene
func load_armory() -> void:
	for i : int in Globals.armory.keys():
		var weapon_name : String = Globals.armory[i]
		var scene : PackedScene = load("res://Entities/Weapons/%d/%s/%s.tscn" % [i,weapon_name,weapon_name])
		var weapon : Weapon = scene.instantiate()
		weapon.name = weapon_name
		weapon.weapon_used.connect(_on_weapon_weapon_used)
		weapon.combat_fin.connect(_on_weapon_combat_fin.bind(weapon))
		weapon.crit.connect(_on_weapon_crit)
		weapon.hp_update.connect(_on_weapon_hp_update)
		weapon.pause.connect(_on_weapon_pause)
		weapon.resume.connect(_on_weapon_resume)
		player.anim_finished.connect(weapon._on_player_anim_finished)
		player.attack_impact.connect(weapon._on_player_attack_impact)
		player.weap_effect_start.connect(weapon._on_player_weap_effect_start)
		add_child(weapon)
		
		# After because property gets assigned after added to tree
		if weapon.has_special:
			player.special_impact.connect(weapon._on_player_special_impact)
		
		player_weapons[i] = weapon

## Marks weapon as active for purposes of weapon signals. Avoids all weapons activating signals
func active_weapon(_weapon : Weapon = null) -> void:
	for weapon : Weapon in player_weapons.values():
		weapon.active = false
	if _weapon:
		_weapon.active = true

func load_weapons_display() -> void:
	weapons_display.drawn.connect(_on_draw_button_pressed)
	weapons_display.weapon_box_click.connect(_on_weapon_box_click)
	weapons_display.cut.connect(_on_cut_button_pressed)
	weapons_display.socket.connect(_on_socket_button_pressed)
	weapons_display.weapon_display_update.connect(_on_weapon_display_update)

func reset_globals() -> void:
	pause_input = false
	chaining = false
	attacks = Globals.attacks
	actions = Globals.actions

func spawn_enemy(num : int = 1, enemy_data : Dictionary = {}) -> void:
	for i : int in range(num):
		enemies = get_tree().get_nodes_in_group("enemies")
		var enemy : Enemy = Enemy.new_enemy(MiniCard.Suits.HEART, range(3,4)) # 2 * (2 + randi() % 2)
		enemy.position = enemy_positions[enemies.size()]
		enemy.z_index -= enemies.size()-1
		
		if enemy_data:
			for prop : String in enemy_data.keys():
				if prop == "filename" or prop == "parent" or prop == "pos_x" or prop == "pos_y":
					continue
				enemy.set(prop, enemy_data[prop])
			#enemy.position = Vector2(enemy_data["pos_x"], enemy_data["pos_y"])
		
		add_child(enemy)
		enemy.animation_player.animation_finished.connect(_on_enemy_animation_finished.bind(enemy))
		enemy.damaged.connect(_on_enemy_damaged.bind(enemy))
		enemy.freed.connect(_on_enemy_freed)
	
		for weapon : Weapon in player_weapons.values():
			enemy.attack_impact.connect(weapon._on_enemy_attack_impact.bind(enemy))
			enemy.rank_update.connect(weapon._on_enemy_rank_update.bind(enemy))
			enemy.attack_prevented.connect(weapon._on_enemy_attack_prevented.bind(enemy))
			enemy.freed.connect(weapon._on_enemy_freed)
			weapon._on_enemy_spawned(enemy)
			
		await get_tree().create_timer(0.2).timeout
	
	await align_enemies(false)
	

func align_enemies(tweening : bool = true) -> void:
	pause_input = true
	await weapon_pause()
	enemies = get_tree().get_nodes_in_group("enemies")
	for i : int in enemies.size():
		if tweening:
			var tween : Tween = create_tween()
			tween.tween_property(enemies[i], "position", enemy_positions[i], 0.3) \
			 .set_trans(Tween.TRANS_SINE)\
			 .set_ease(Tween.EASE_OUT)
			if i == enemies.size() - 1:
				await tween.finished
		else:
			enemies[i].position = enemy_positions[i]
			enemies[i].z_index = 5 - i
	
	pause_input = false


func initiate_combat() -> void:
	enemies = get_tree().get_nodes_in_group("enemies")
	if curr_weapon:
		combat_data = curr_weapon.resolve_combat()
		return
	else:
		var target : Enemy = enemies[0]
		combat_data = target.attack(null, combat_data)
		for weapon : Weapon in player_weapons.values():
			weapon.combat_data = combat_data
		if target.animation_player.current_animation.contains("attack"):
			await target.attack_impact
			player.play("base_defend")
		else:
			await target.animation_player.animation_finished
		_on_weapon_hp_update(combat_data["hp_delta"])
		await player.anim_finished
		_on_weapon_combat_fin(null)
	
#endregion

func update_crit_button() -> void:
	crit_button.spawn(crits_stored > 0)
	crit_button.update_crits_stored(crits_stored)
	
	
	enemies = get_tree().get_nodes_in_group("enemies").filter(func(e : Enemy) -> bool: return e != null and not e.is_dead)
	
	# Crit Button enable/disable
	crit_button.enable(false)
	if curr_weapon and curr_weapon.has_special and curr_weapon.has_valid_spec_target(enemies):
		if crits_stored >= curr_weapon.special_cost:
			crit_button.enable()

func weapon_pause() -> void:
	while !pausing_weapons.is_empty():
		await get_tree().process_frame
	return

func update_attack_buttons() -> void:
	if mini_equipped and !chaining and !enemies.is_empty():
		attack_button.disabled = false
		chain_button.disabled = false
	else:
		attack_button.disabled = true
		chain_button.disabled = true


var enemy_just_attacked : bool = false
func update_turn_clock() -> void:
	
	# Flip clock if turn order is flipped 
	var tween : Tween = create_tween()
	tween.tween_property(turn_clock, "scale", Vector2(1, 1 - 2 * int(turn_order_flipped)), 0.3) \
	 .set_trans(Tween.TRANS_SINE)\
	 .set_ease(Tween.EASE_OUT)
	
	# Adjust clock hand
	enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		turn_clock.show_turn(turn_clock.turn.HALF)
		return
		
	var target : Enemy = enemies[0]
	if enemies.is_empty() or target.rank <= 0 or !mini_equipped \
			or (enemy_just_attacked and mini_equipped.used):
		
		turn_clock.show_turn(turn_clock.turn.HALF)
		return
	
	if (target.rank >= mini_equipped.rank and !mini_equipped.used) \
			or enemy_just_attacked or target.attack_disabled or target.slowed:
				
		turn_clock.show_turn(turn_clock.turn.DOWN)
	else:
		turn_clock.show_turn(turn_clock.turn.UP)

func update_tatters() -> void:
	var updating_tatters : bool = true
	while updating_tatters:
		var prev_tat_count : int = int(tatter_count_label.text)
		if !Globals.inventory.has("tatter"):
			tatter_count.hide()
			updating_tatters = false
			return
		
		var curr_tat_count : int = Globals.inventory["tatter"].count
		
		tatter_count.show()
		
		if prev_tat_count == curr_tat_count:
			updating_tatters = false
			return
		
		tatter_count_label.text = "%.0f" % move_toward(prev_tat_count, curr_tat_count, 1)
		await get_tree().create_timer(.1).timeout

# Mini MiniCards
#-------------------------------------------------------------------------------
#region

## Spawn card. ONLY USE WHEN LOADING SAVE. NO CHECKS FOR GOING OVER LIMIT
func spawn_card(mini_data : Dictionary) -> void:
	var mini_card : MiniCard = MiniCard.new_random_card(Globals.armory.keys())
	mini_card.position = armory_position
	add_child(mini_card)
	
	Globals.assign_vars_from_dict(mini_card, mini_data)
	mini_card.update_visuals()
	
	mini_card.input_event.connect(_on_mini_card_input_event.bind(mini_card))
	mini_card.mouse_entered.connect(_on_mini_card_mouse_entered.bind(mini_card))
	mini_card.mouse_exited.connect(_on_mini_card_mouse_exited.bind(mini_card))
	mini_card.free.connect(_on_mini_card_free)
	return

## Draws card through joker animation
func draw_card(amount : int = 1) -> void:
	var available_slots : int = \
		Globals.max_draw - get_tree().get_node_count_in_group("mini_cards") - int(mini_equipped != null)
	
	drawing = true
	amount = min(amount, available_slots)
	
	if amount <= 0:
		push_error("No space to draw")
		pause_input = false
		
	for i : int in range(amount):
		var mini_card : MiniCard = MiniCard.new_random_card(Globals.armory.keys())
		mini_card.position = armory_position
		mini_card.visible = false
		add_child(mini_card)
		
		# Equips only first one
		if i == 0:
			equip_mini_card(mini_card, false)
		
		
		# Signals
		mini_card.input_event.connect(_on_mini_card_input_event.bind(mini_card))
		mini_card.mouse_entered.connect(_on_mini_card_mouse_entered.bind(mini_card))
		mini_card.mouse_exited.connect(_on_mini_card_mouse_exited.bind(mini_card))
		mini_card.free.connect(_on_mini_card_free)
	return

func align_mini_cards(tweening : bool = true) -> void:
	var spacing : float = 30
	var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
	var num_cards : int = get_tree().get_node_count_in_group("mini_cards")
	var half : float = (num_cards - 1) / 2.0
	var positions : Array[Vector2]
	
	# Sort nodes based on current x position to account for dragging
	mini_cards.sort_custom(func(a: MiniCard, b: MiniCard) -> bool: \
		return a.global_position.x < b.global_position.x)
	
	for i : int in range(num_cards):
		var offset_x : float = (i - half) * spacing
		positions.append(armory_position + Vector2(offset_x, 0))
	
	for i : int in range(mini_cards.size()):
		if mini_cards[i] != mini_equipped:
			mini_cards[i].visible = true
		mini_cards[i].z_index =  11
		if tweening:
			var tween : Tween = create_tween()
			tween.tween_property(mini_cards[i], "position", positions[i], 0.3) \
			 .set_trans(Tween.TRANS_SINE)\
			 .set_ease(Tween.EASE_OUT)
		else:
			mini_cards[i].global_position = positions[i]

func equip_mini_card(mini_card : MiniCard = null, player_update : bool = true) -> void:
	
	if mini_card:
		if curr_weapon:
			curr_weapon.unequip()
			
		curr_weapon =  player_weapons[mini_card.rank]
		curr_weapon.player = player
		curr_weapon.enemies = get_tree().get_nodes_in_group("enemies")
		active_weapon(curr_weapon)
		if mini_equipped and mini_equipped != mini_card:
			
			# Position
			var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards") 
			mini_cards.sort_custom(func(a: MiniCard, b: MiniCard) -> bool: \
			return a.global_position.x < b.global_position.x)
			mini_equipped.position = mini_cards.back().position + Vector2(30,0)
			mini_equipped.visible = true
			mini_equipped.add_to_group("mini_cards")
		mini_card.play("equip")
		mini_equipped = mini_card
		mini_equipped.remove_from_group("mini_cards")
		
	else:
		if curr_weapon:
			curr_weapon.unequip()
		curr_weapon =  null
		active_weapon(null)
		
		if mini_equipped:
			mini_equipped.position = armory_position + (Vector2(30,0) * get_tree().get_node_count_in_group("mini_cards"))
			mini_equipped.visible = true
			mini_equipped.queue("spawn")
			mini_equipped.add_to_group("mini_cards")
		mini_equipped = null
	
	
	# DISPLAY
	# Update Child's variables
	weapons_display.displayed_weapon = curr_weapon
	weapons_display.card = mini_equipped
	
	# PLAYER
	# Only update when equipping different weapon
	if player_update:
		if curr_weapon:
			curr_weapon.equip()
		else:
			player.play("base_idle")
	
	# Doesn't update weapon display until after drawing
	if !drawing:
		update_attack_buttons()
		weapons_display.display_weapon(curr_weapon, mini_equipped, actions)
		
		# Show Draw Button
		var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
		var space_in_armory : bool = Globals.max_draw > mini_cards.size() + int(mini_equipped != null)
		if !space_in_armory:
			weapons_display.buttons_enabled(space_in_armory, true)
		
		
		update_crit_button()
		update_turn_clock()
	
	
	align_mini_cards()
#endregion

# === Built In =================================================================
#region
func _ready() -> void:
	hp = Globals.hp
	hands_label.text = "Hand: %d/%d" % [curr_round, max_rounds]
	
	load_armory()
	load_weapons_display()
	equip_mini_card(null)
	update_tatters()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if pause_input:
		return
	
	elif event.is_action_pressed("draw_button"):
		if actions <= 0:
			return
		_on_draw_button_pressed()
	elif event.is_action_pressed("attack_button"):
		_on_attack_button_pressed()
	elif event.is_action_pressed("chain_button"):
		_on_chain_button_pressed()
	elif event.is_action_pressed("pass_button"):
		equip_mini_card(null)
		pause_input = true
		initiate_combat()
		

func _process(_delta: float) -> void:
	if dragging and dragged_card:
		dragged_card.z_index = 12
		dragged_card.position = get_global_mouse_position()
		
	if crit_infinite:
		crits_stored = 3

		
		
#endregion

# === Signals ==================================================================
# UI
#-------------------------------------------------------------------------------
#region

func _on_weapon_box_click() -> void:
	if pause_input:
		return
	equip_mini_card(null)
	
func _on_draw_button_pressed() -> void:
	if pause_input:
		return
		
	weapons_display.buttons_enabled(false)
	weapons_display.play("RESET")
	pause_input = true
	if get_tree().get_node_count_in_group("mini_cards") + int(mini_equipped != null) >= Globals.max_draw:
		pause_input = false
		return
	actions -= 1
	draw_card(Globals.draw_amt)
	weapons_display.play("joker_open_mouth")

func _on_cut_button_pressed() -> void:
	if pause_input:
		return
	var cut : bool = mini_equipped.cut()
	if !cut:
		return
	actions -= 1
	equip_mini_card(mini_equipped)

func _on_socket_button_pressed() -> void:
	if pause_input:
		return
	var socketed : bool = mini_equipped.socket()
	if !socketed:
		return
	actions -= 1
	equip_mini_card(mini_equipped)

func _on_attack_button_pressed() -> void:
	if pause_input:
		return
	attack_button.disabled = true
	chain_button.disabled = true
	if !curr_weapon or get_tree().get_nodes_in_group("enemies").is_empty():
		return
	pause_input = true
	if !curr_weapon or get_tree().get_nodes_in_group("enemies").is_empty():
		return
	initiate_combat()


func _on_chain_button_pressed() -> void:
	if pause_input:
		return
	attack_button.disabled = true
	chain_button.disabled = true
	if !curr_weapon or get_tree().get_nodes_in_group("enemies").is_empty():
		return
	pause_input = true
	chaining = true
	initiate_combat()
	

func _on_crit_button_pressed() -> void:
	if crits_stored <= 0 or pause_input:
		return
	pause_input = true
	crit_button.enable(false)
	crits_stored = clamp(crits_stored - curr_weapon.special_cost, 0, Globals.max_crits)
	
	enemies = get_tree().get_nodes_in_group("enemies")
	curr_weapon.special_attack()
	
	#Visuals
	await player.special_impact
	weapons_display.play("joker_crit_expend")

## Emitted by weapon display once ready for update
func _on_weapon_display_update() -> void:
	if drawing:
		align_mini_cards()
		if mini_equipped:
			curr_weapon.equip()
			update_attack_buttons()
			update_turn_clock()
			update_crit_button()
		else:
			player.play("base_idle")
			attack_button.disabled = true
			chain_button.disabled = true
		pause_input = false
		drawing = false
		
#endregion



# Mini MiniCards
#-------------------------------------------------------------------------------
#region

# MiniCard dragging and equipping
var click_pos : Vector2 = Vector2.ZERO
var dragging: bool = false
var dragged_card : MiniCard = null
const DRAG_THRESHOLD : float = 2.0

func _on_mini_card_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, mini_card : MiniCard) -> void:
	if !spam_timer.is_stopped() or pause_input or mini_card.used:
		return
	
	if dragged_card and mini_card != dragged_card:
		return
	
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			click_pos = event.position
			dragging = false
			dragged_card = null
		else:
			# Letting go of mouse button. If you were dragging or not
			if !dragging:
				equip_mini_card(mini_card)
				spam_timer.wait_time = 0.5
				spam_timer.start()
			else:
				# Equips if dragged over weapons display
				if dragged_card and dragged_card.global_position.x > 490:
					equip_mini_card(dragged_card)
				dragging = false
				align_mini_cards()
				await get_tree().create_timer(.1).timeout # Prevents drawing minicard when hovering over another card
				dragged_card = null
				
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.position.distance_to(click_pos) > DRAG_THRESHOLD:
			dragging = true
			dragged_card = mini_card
			

func _on_mini_card_mouse_entered(mini_card : MiniCard) -> void:
	if dragging or mini_card.used:
		return
	
	for card : MiniCard in get_tree().get_nodes_in_group("mini_cards"):
		card.deselect()
	mini_card.select()
	
func _on_mini_card_mouse_exited(mini_card : MiniCard) -> void:
	mini_card.deselect()

func _on_mini_card_free(mini_card : MiniCard) -> void:
	if mini_card == mini_equipped:
		await player.anim_finished
		equip_mini_card(null)

func _on_spam_timer_timeout() -> void:
	pass

#endregion

# Weapons
#-------------------------------------------------------------------------------
#region

## Only called when player card < enemy card. After weapon is used and must be uneqipped
## Do not call if enemy died from attack
func _on_weapon_weapon_used(_weapon : Weapon) -> void:
	if !_weapon.active:
		return
	await weapon_pause()
	
	update_turn_clock()
	
	var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
	enemies = get_tree().get_nodes_in_group("enemies")
	
	# If all weapons have been used
	if mini_cards.all(func(n : MiniCard) -> bool: return n.used) or mini_cards.size() == 0:
		attacks = 0
		await get_tree().create_timer(0.3).timeout # Allow turnclock to adjust
		initiate_combat() # Resolves combat with defend
		return
		
	# Chaining
	if chaining and !enemies[0].is_dead:
		# Sort minis by order in player armory
		mini_cards.sort_custom(func(a: MiniCard, b: MiniCard) -> bool: \
			return a.global_position.x < b.global_position.x)
			
		var sorted_unused : Array = mini_cards.filter(func(e : MiniCard) -> bool: return !e.used)
		sorted_unused.erase(mini_equipped)
		var next_mini : MiniCard = sorted_unused[0]
		equip_mini_card(next_mini)
		initiate_combat()
	else:
		await weapon_pause()
		pause_input = false
		equip_mini_card(null)
	

## After weapon is used and combat cycle restarts
func _on_weapon_combat_fin(_weapon : Weapon) -> void:
	
	pause_input = true
	
	for weapon : Weapon in player_weapons.values():
		weapon.post_combat()
		await weapon_pause()
	
	reset_globals()
	
	pause_input = false
	
	var mini_cards : Array= get_tree().get_nodes_in_group("mini_cards")
	var space_in_armory : bool = Globals.max_draw > mini_cards.size() + int(mini_equipped != null)
	
	# Reset Used MiniCards
	for mini_card : MiniCard in mini_cards:
		mini_card.used = false
	
	if mini_equipped:
		mini_equipped.used = false
	
	
	# Unequip if space in armory
	if space_in_armory:
		weapons_display.play("draw_highlight")
		equip_mini_card(null)
	
	# Stops player from equipping when round is over
	if curr_weapon:
		curr_weapon.equip()
		#equip_mini_card(mini_equipped)
	
	update_attack_buttons()
	update_crit_button()

func _on_weapon_crit() -> void:
	weapons_display.play("joker_crit")
	crits_stored = clamp(crits_stored + 1, 0, Globals.max_crits)
	update_crit_button()
	

func _on_weapon_hp_update(_hp_delta : int = combat_data["hp_delta"]) -> void:
	# HP
	hp = clamp(hp + _hp_delta, 0, Globals.max_hp)
	health_bar.display_hp(hp, Globals.max_hp)

func _on_weapon_pause(_weapon : Weapon) -> void:
	pausing_weapons.append(_weapon)

func _on_weapon_resume(_weapon : Weapon) -> void:
	pausing_weapons.erase(_weapon)

#endregion

func _on_enemy_damaged(_amt : int, _enemy : Enemy) -> void:
	if curr_weapon:
		camera.shake(curr_weapon.rank / 2.0)

func _on_enemy_animation_finished(anim : String, enemy : Enemy) -> void:
	enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty() or enemy != enemies[0]:
		return
	if anim.contains("attack"):
		enemy_just_attacked = true
		update_turn_clock()
		enemy_just_attacked = false

func _on_enemy_freed(_enemy : Enemy) -> void:
	# Loot
	var loot_dict : Dictionary = _enemy.generate_loot()
	for item : String in loot_dict.keys():
		if item == "tatter":
			tatters_particle.position = _enemy.position
			tatters_particle.z_index = _enemy.z_index + 1
			tatters_particle.amount = loot_dict["tatter"]
			tatters_particle.emitting = true
		Globals.add_item(item, loot_dict[item])
	
	
	enemies.erase(_enemy)
	await _enemy.tree_exited
	var player_animation : String = player.animation_player.current_animation
	if player_animation.contains("attack") or player_animation.contains("special"):
		await player.anim_finished
	enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		end_round()
	else:
		align_enemies()
	update_turn_clock()
	update_tatters()
