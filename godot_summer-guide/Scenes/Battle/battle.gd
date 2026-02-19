extends Node2D

@onready var player : Node2D = $Player
@onready var weapons_display : Control = $UI/WeaponDisplay
@onready var health_bar : PanelContainer = $UI/HealthBar
@onready var chain_button : TextureButton = $UI/AttackButtons/MarginContainer/VBoxContainer/PanelContainer2/ChainButton
@onready var attack_button : TextureButton = $UI/AttackButtons/MarginContainer/VBoxContainer/PanelContainer/AttackButton
@onready var crit_button : TextureButton = $UI/CritButton
@onready var turn_clock : Node2D = $UI/TurnClock
@onready var spam_timer : Timer = $SpamTimer

var mini_pos : Array								# Mini Card Positions
var armory_position : Vector2 = Vector2(250,335)
var enemy_target_pos : Vector2 = Vector2(250,80)
var enemy_positions : Array[Vector2] = [enemy_target_pos, enemy_target_pos - Vector2(35,10), enemy_target_pos - Vector2(-30, 20), \
										Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var mini_equipped : Card							# Current card player has equipped
var curr_weapon : Weapon							# String name of player weapon
var player_weapons : Dictionary
var enemies : Array
var hp : int
var attacks : int = Globals.attacks					# Attacks player has left
var actions : int = Globals.actions					# Actions player has left (draw, cut, socket)
var drawing : bool = false							# Turned on when drawing started, off when it ends
var chaining : bool = false							# Turned on when chain attack is occuring
var crit_stored : int = 0							# Number of crits stored
var click_prevention : bool = false					# Stops minicard/attack inputs when drawing or attacking
var pausing_weapons : Array[Weapon]					# Weapon pausing chaining for effects to take place

var combat_data : Dictionary
var turn_order_flipped : bool = true

# DEV TOOLS
var crit_infinite : bool = true

# === Custom Methods ===========================================================
# General
#-------------------------------------------------------------------------------
#region
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
	click_prevention = false
	chaining = false
	attacks = Globals.attacks
	actions = Globals.actions

func spawn_enemy(num : int = 1) -> void:
	for i : int in range(num):
		enemies = get_tree().get_nodes_in_group("enemies")
		var enemy : Enemy = Enemy.new_enemy(Card.Suits.HEART,[6]) # 2 * (2 + randi() % 2)
		enemy.name = "Enemy%d" % [randi()%10000]
		enemy.position = enemy_positions[enemies.size()]
		enemy.z_index -= enemies.size()-1
		add_child(enemy)
		enemy.animation_player.animation_finished.connect(_on_enemy_animation_finished.bind(enemy))
		enemy.freed.connect(_on_enemy_freed)
	
		for weapon : Weapon in player_weapons.values():
			enemy.attack_impact.connect(weapon._on_enemy_attack_impact.bind(enemy))
			enemy.rank_update.connect(weapon._on_enemy_rank_update.bind(enemy))
			enemy.attack_prevented.connect(weapon._on_enemy_attack_prevented.bind(enemy))
			enemy.freed.connect(weapon._on_enemy_freed)
			weapon._on_enemy_spawned(enemy)
			
		await get_tree().create_timer(0.2).timeout
	
	align_enemies(false)
	

func align_enemies(tweening : bool = true) -> void:
	await weapon_pause()
	enemies = get_tree().get_nodes_in_group("enemies")
	for i : int in enemies.size():
		if tweening:
			var tween : Tween = create_tween()
			tween.tween_property(enemies[i], "position", enemy_positions[i], 0.3) \
			 .set_trans(Tween.TRANS_SINE)\
			 .set_ease(Tween.EASE_OUT)
		else:
			enemies[i].position = enemy_positions[i]
			enemies[i].z_index = 5 - i
	pass


func initiate_combat() -> void:
	enemies = get_tree().get_nodes_in_group("enemies")
	if curr_weapon:
		combat_data = curr_weapon.resolve_combat()
		return
	else:
		combat_data = enemies[0].attack(null, combat_data)
		await enemies[0].attack_impact
		player.play("base_defend")
		_on_weapon_hp_update(combat_data["hp_delta"])
		await player.anim_finished
		_on_weapon_combat_fin(null)
	
#endregion

func update_crit_button() -> void:
	crit_button.spawn(crit_stored > 0)
	crit_button.update_crit_stored(crit_stored)
	
	
	enemies = get_tree().get_nodes_in_group("enemies").filter(func(e : Enemy) -> bool: return e != null and not e.is_dead)
	
	# Crit Button enable/disable
	crit_button.enable(false)
	if curr_weapon and curr_weapon.has_special and curr_weapon.has_valid_spec_target(enemies):
		if crit_stored >= curr_weapon.special_cost:
			crit_button.enable()

func weapon_pause() -> Signal:
	if pausing_weapons.is_empty():
		return get_tree().process_frame
	else:
		while !pausing_weapons.is_empty():
			await get_tree().process_frame
		return get_tree().process_frame

var enemy_just_attacked : bool = false
func update_turn_clock() -> void:
	enemies = get_tree().get_nodes_in_group("enemies")
	var target : Enemy = enemies[0]
	if enemies.is_empty() or target.rank <= 0 or !mini_equipped:
		turn_clock.show_turn(turn_clock.turn.HALF)
		return
	
	if (target.rank >= mini_equipped.rank and !mini_equipped.used) or enemy_just_attacked or target.attack_disabled or target.slowed:
		turn_clock.show_turn(turn_clock.turn.DOWN)
	else:
		turn_clock.show_turn(turn_clock.turn.UP)
	

# Mini Cards
#-------------------------------------------------------------------------------
#region

func draw_card(amount : int = 1) -> void:
	var available_slots : int = \
		Globals.max_draw - get_tree().get_node_count_in_group("mini_cards") - int(mini_equipped != null)
	
	drawing = true
	amount = min(amount, available_slots)
	
	if amount <= 0:
		push_error("No space to draw")
		click_prevention = false
		
	for i : int in range(amount):
		var mini_card : Card = Card.new_random_card(Globals.armory.keys())
		mini_card.name = "MiniCard%d" % [randi()%10000]
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
	mini_cards.sort_custom(func(a: Card, b: Card) -> bool: \
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

func equip_mini_card(mini_card : Card = null, player_update : bool = true) -> void:
	
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
			mini_cards.sort_custom(func(a: Card, b: Card) -> bool: \
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
		player.queue("base_idle")
		
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
	
	
	# Doesn't update weapon display until after drawing
	if !drawing:
		if mini_equipped and !chaining:
			attack_button.disabled = false
			chain_button.disabled = false
		else:
			attack_button.disabled = true
			chain_button.disabled = true
		weapons_display.display_weapon(curr_weapon, mini_equipped, actions)
		
		# Show Draw Button
		var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
		var space_in_armory : bool = Globals.max_draw > mini_cards.size() + int(mini_equipped != null)
		if !space_in_armory:
			weapons_display.buttons_enabled(space_in_armory, true)
		
		
		update_crit_button()
		update_turn_clock()
	
	# PLAYER
	# Only update when equipping different weapon
	if player_update:
		if curr_weapon:
			curr_weapon.equip()
		else:
			player.play("base_idle")
	
	align_mini_cards()
#endregion

# === Built In =================================================================
#region
func _ready() -> void:
	hp = Globals.hp
	
	load_armory()
	load_weapons_display()
	spawn_enemy(3)
	equip_mini_card(null)
	
	# Runs after first frame
	#await get_tree().process_frame

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
		
	if click_prevention:
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
		initiate_combat()
		

func _process(_delta: float) -> void:
	if dragging and dragged_card:
		dragged_card.z_index = 12
		dragged_card.position = get_global_mouse_position()
		
	if crit_infinite:
		crit_stored = 3
#endregion

# === Signals ==================================================================
# UI
#-------------------------------------------------------------------------------
#region

func _on_weapon_box_click() -> void:
	if click_prevention:
		return
	equip_mini_card(null)
	
func _on_draw_button_pressed() -> void:
	if click_prevention:
		return
		
	weapons_display.buttons_enabled(false)
	click_prevention = true
	if get_tree().get_node_count_in_group("mini_cards") + int(mini_equipped != null) >= Globals.max_draw:
		click_prevention = false
		return
	actions -= 1
	draw_card(Globals.draw_amt)
	weapons_display.play("joker_open_mouth")

func _on_cut_button_pressed() -> void:
	if click_prevention:
		return
	var cut : bool = mini_equipped.cut()
	if !cut:
		return
	actions -= 1
	equip_mini_card(mini_equipped)

func _on_socket_button_pressed() -> void:
	if click_prevention:
		return
	var socketed : bool = mini_equipped.socket()
	if !socketed:
		return
	actions -= 1
	equip_mini_card(mini_equipped)

func _on_attack_button_pressed() -> void:
	if click_prevention:
		return
	attack_button.disabled = true
	chain_button.disabled = true
	if !curr_weapon or get_tree().get_nodes_in_group("enemies").is_empty():
		return
	click_prevention = true
	if !curr_weapon or get_tree().get_nodes_in_group("enemies").is_empty():
		return
	initiate_combat()


func _on_chain_button_pressed() -> void:
	if click_prevention:
		return
	attack_button.disabled = true
	chain_button.disabled = true
	if !curr_weapon or get_tree().get_nodes_in_group("enemies").is_empty():
		return
	click_prevention = true
	chaining = true
	initiate_combat()
	

func _on_crit_button_pressed() -> void:
	if crit_stored <= 0 or click_prevention:
		return
	click_prevention = true
	crit_button.enable(false)
	crit_stored = clamp(crit_stored - curr_weapon.special_cost, 0, Globals.max_crits)
	
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
			attack_button.disabled = false
			chain_button.disabled = false
			curr_weapon.equip()
			update_turn_clock()
			update_crit_button()
		else:
			player.play("base_idle")
			attack_button.disabled = true
			chain_button.disabled = true
		click_prevention = false
		drawing = false
		
#endregion



# Mini Cards
#-------------------------------------------------------------------------------
#region

# Card dragging and equipping
var click_pos : Vector2 = Vector2.ZERO
var dragging: bool = false
var dragged_card : Card = null
const DRAG_THRESHOLD : float = 2.0

func _on_mini_card_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, mini_card : Card) -> void:
	if !spam_timer.is_stopped() or click_prevention or mini_card.used:
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
				if dragged_card.global_position.x > 490:
					equip_mini_card(dragged_card)
				dragging = false
				align_mini_cards()
				await get_tree().create_timer(.1).timeout # Prevents drawing minicard when hovering over another card
				dragged_card = null
				
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.position.distance_to(click_pos) > DRAG_THRESHOLD:
			dragging = true
			dragged_card = mini_card
			

func _on_mini_card_mouse_entered(mini_card : Card) -> void:
	if dragging or mini_card.used:
		return
	
	for card : Card in get_tree().get_nodes_in_group("mini_cards"):
		card.deselect()
	mini_card.select()
	
func _on_mini_card_mouse_exited(mini_card : Card) -> void:
	mini_card.deselect()

func _on_mini_card_free(mini_card : Card) -> void:
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

	var mini_cards : Array = get_tree().get_nodes_in_group("mini_cards")
	enemies = get_tree().get_nodes_in_group("enemies")
	
	# If all weapons have been used
	if mini_cards.all(func(n : Card) -> bool: return n.used) or mini_cards.size() == 0:
		attacks = 0
		initiate_combat() # Resolves combat with defend
		return
		
	# Chaining
	if chaining and !enemies[0].is_dead:
		# Sort minis by order in player armory
		mini_cards.sort_custom(func(a: Card, b: Card) -> bool: \
			return a.global_position.x < b.global_position.x)
			
		var sorted_unused : Array = mini_cards.filter(func(e : Card) -> bool: return !e.used)
		sorted_unused.erase(mini_equipped)
		var next_mini : Card = sorted_unused[0]
		equip_mini_card(next_mini)
		await get_tree().create_timer(0.2).timeout
		initiate_combat()
	else:
		click_prevention = false
		equip_mini_card(null)
	

## After weapon is used and combat cycle restarts
func _on_weapon_combat_fin(_weapon : Weapon) -> void:
	for weapon : Weapon in player_weapons.values():
		weapon.post_combat()
		await weapon_pause()
	
	reset_globals()
	
	var mini_cards : Array= get_tree().get_nodes_in_group("mini_cards")
	var space_in_armory : bool = Globals.max_draw > mini_cards.size() + int(mini_equipped != null)
	
	# Reset Used Cards
	for mini_card : Card in mini_cards:
		mini_card.play("RESET")
		mini_card.used = false
	if mini_equipped:
		mini_equipped.play("RESET")
		mini_equipped.used = false
	
	# Unequip if space in armory
	if space_in_armory:
		weapons_display.play("draw_highlight")
		equip_mini_card(null)
	
	equip_mini_card(mini_equipped)
	

func _on_weapon_crit() -> void:
	weapons_display.play("joker_crit")
	crit_stored = clamp(crit_stored + 1, 0, Globals.max_crits)
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

func _on_enemy_animation_finished(anim : String, enemy : Enemy) -> void:
	enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty() or enemy != enemies[0]:
		return
	if anim.contains("attack"):
		enemy_just_attacked = true
		update_turn_clock()
		enemy_just_attacked = false

func _on_enemy_freed(_enemy : Enemy) -> void:
	enemies.erase(_enemy)
	await _enemy.tree_exited
	var player_animation : String = player.animation_player.current_animation
	if player_animation.contains("attack") or player_animation.contains("special"):
		await player.anim_finished
	enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		spawn_enemy(3)
	else:
		align_enemies()
	update_turn_clock()
