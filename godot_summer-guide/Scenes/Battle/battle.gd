extends Node2D

@onready var player : Node2D = $Player
@onready var weapons_display : Control = $UI/WeaponDisplay
@onready var attack_button : TextureButton = $UI/PanelContainer/AttackButton
@onready var spam_timer : Timer = $SpamTimer

var mini_pos : Array								# Mini Card Positions
var armory_position : Vector2 = Vector2(250,335)
var enemy_positions : Array[Vector2] = [Vector2(250,80), Vector2(215,70), Vector2(280, 60), \
										Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
var mini_cards : Array[Card]						# Stores drawn card nodes
var mini_equipped : Card							# Current card player has equipped
var curr_weapon : Weapon							# String name of player weapon
var player_weapons : Dictionary
var hp : float = 100
var attacks : int = Globals.attacks								# Attacks player has left
var actions : int = Globals.actions								# Actions player has left (draw, cut, polish)
var enemies : Array[Enemy]
var drawing : bool = false

# === Custom Methods ===========================================================
# General
#-------------------------------------------------------------------------------
#region
## Loads all player weapons into scene
func load_armory() -> void:
	for i : int in Globals.armory.keys():
		var weapon_name : String = Globals.armory[i]
		
		var scene : PackedScene = load("res://Entities/Weapons/%d/%s.tscn" % [i,weapon_name])
		var weapon : Weapon = scene.instantiate()
		weapon.name = weapon_name
		weapon.weapon_used.connect(_on_weapon_weapon_used)
		weapon.combat_fin.connect(_on_weapon_combat_fin.bind(weapon))
		weapon.crit.connect(_on_weapon_crit)
		player.anim_finished.connect(weapon._on_player_anim_finished)
		player.attack_impact.connect(weapon._on_player_attack_impact)
		add_child(weapon)
		
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
	weapons_display.polish.connect(_on_polish_button_pressed)
	weapons_display.weapon_display_update.connect(_on_weapon_display_update)

func spawn_enemy(num : int = 1) -> void:
	for i : int in range(num):
		
		var enemy : Enemy = Enemy.new_enemy(Card.Suits.HEART, randi() % 10 + 1)
		enemy.position = Vector2(250,80)
		add_child(enemy)
		enemies.append(enemy)
		enemy.freed.connect(_on_enemy_freed)
	
		for weapon : Weapon in player_weapons.values():
			enemy.attack_impact.connect(weapon._on_enemy_attack_impact)
	
	align_enemies()

func align_enemies() -> void:
	for i : int in enemies.size():
		enemies[i].position = enemy_positions[i]
		enemies[i].z_index = 5 - i
	pass
	

func initiate_combat() -> void:
	var combat_data : Dictionary = curr_weapon.resolve_combat(player, hp, attacks, enemies)
	mini_equipped.damage(combat_data["durability_lost"])
	equip_mini_card(mini_equipped, false)
	
	
#endregion

# Mini Cards
#-------------------------------------------------------------------------------
#region

func draw_card(amount : int = 1) -> void:
	drawing = true
	var available_slots : int = Globals.max_draw - mini_cards.size()
	amount = min(amount, available_slots)
	
	for i : int in range(amount):
		var mini_card : Card = Card.new_random_card(Globals.armory.keys())
		mini_card.name = "MiniCard"
		mini_card.position = armory_position
		mini_card.visible = false
		add_child(mini_card)
		mini_cards.append(mini_card)
		
		# Equips only first one
		if i == 0:
			equip_mini_card(mini_card, false)
		
		
		# Signals
		mini_card.input_event.connect(_on_mini_card_input_event.bind(mini_card))
		mini_card.mouse_entered.connect(_on_mini_card_mouse_entered.bind(mini_card))
		mini_card.mouse_exited.connect(_on_mini_card_mouse_exited.bind(mini_card))
		mini_card.free.connect(_on_mini_card_free)
		
	mini_cards = mini_cards.filter(func(e : Card) -> bool: return e != null)		# Remove Null values
	return

func align_mini_cards(tweening : bool = true) -> void:
	var spacing : float = 30
	var num_cards : int = mini_cards.size()
	var half : float = (num_cards - 1) / 2.0
	var positions : Array[Vector2]
	
	# Sort nodes based on current x position to account for dragging
	mini_cards.sort_custom(func(a: Card, b: Card) -> bool: \
		return a.global_position.x < b.global_position.x)
	
	for i : int in range(num_cards):
		var offset_x : float = (i - half) * spacing
		positions.append(armory_position + Vector2(offset_x, 0))
	
	for i : int in range(mini_cards.size()):
		mini_cards[i].visible = true
		mini_cards[i].z_index =  11
		if tweening:
			var tween : Tween = create_tween()
			tween.tween_property(mini_cards[i], "position", positions[i], 0.3)\
			 .set_trans(Tween.TRANS_SINE)\
			 .set_ease(Tween.EASE_OUT)
		else:
			mini_cards[i].global_position = positions[i]

func equip_mini_card(mini_card : Card = null, player_update : bool = true) -> void:
	
	if mini_card:
		if mini_card.used:
			return
		curr_weapon =  player_weapons[mini_card.rank]
		curr_weapon.player = player
		curr_weapon.enemies = enemies
		active_weapon(curr_weapon)
		if mini_equipped and mini_equipped != mini_card:
			mini_equipped.position = mini_card.position + Vector2(30,0)
			mini_equipped.visible = true
		mini_card.play("equip")
		mini_cards.append(mini_equipped)
		mini_equipped = mini_card
		mini_cards.erase(mini_equipped)
		
	else:
		curr_weapon =  null
		active_weapon(null)
		player.queue("base_idle")
		
		if mini_equipped:
			mini_equipped.position = armory_position + (Vector2(30,0) * mini_cards.size())
			mini_equipped.visible = true
			mini_equipped.queue("spawn")
			mini_cards.append(mini_equipped)
			mini_equipped = null
	
	mini_cards = mini_cards.filter(func(e : Card) -> bool: return e != null)		# Remove Null values
	
	# Update Child's variables
	weapons_display.displayed_weapon = curr_weapon
	weapons_display.card = mini_equipped
	
	
	# Doesn't update weapon display until after drawing
	if !drawing:
		weapons_display.display_weapon(curr_weapon, mini_equipped, actions)
	
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
	load_armory()
	load_weapons_display()
	
	spawn_enemy(3)
	
	# Runs after first frame
	#await get_tree().process_frame

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_game"):
			get_tree().quit()
	# Case for clicking on nothing
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		pass

func _process(_delta: float) -> void:
	if dragged_card:
		dragged_card.z_index = 12
		dragged_card.position = get_global_mouse_position()

#endregion

# === Signals ==================================================================
# UI
#-------------------------------------------------------------------------------
#region

func _on_weapon_box_click() -> void:
	equip_mini_card(null)
	
func _on_draw_button_pressed() -> void:
	if mini_cards.size() >= Globals.max_draw:
		return
	actions -= 1
	draw_card(Globals.draw_amt)
	weapons_display.play("joker_open_mouth")

func _on_cut_button_pressed() -> void:
	var cut : bool = mini_equipped.cut()
	if !cut:
		return
	equip_mini_card(mini_equipped)
	actions -= 1

func _on_polish_button_pressed() -> void:
	var polished : bool = mini_equipped.polish()
	if !polished:
		return
	equip_mini_card(mini_equipped)
	actions -= 1

func _on_attack_button_pressed() -> void:
	attack_button.disabled = true
	if !spam_timer.is_stopped() or !curr_weapon or !enemies[0]:
		return
	initiate_combat()
	spam_timer.wait_time = 1.0
	spam_timer.start()
	
## Emitted by weapon display once ready for update
func _on_weapon_display_update() -> void:
	align_mini_cards()
	if drawing:
		if mini_equipped:
			attack_button.visible = true
			curr_weapon.equip()
		else:
			player.play("base_idle")
			attack_button.visible = false
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
	if !spam_timer.is_stopped():
		return
	
	if dragging and mini_card != dragged_card:
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
				dragged_card = null
				align_mini_cards()
				
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.position.distance_to(click_pos) > DRAG_THRESHOLD:
			dragging = true
			dragged_card = mini_card
			

func _on_mini_card_mouse_entered(mini_card : Card) -> void:
	if dragging or mini_card.used:
		return
	
	for card : Card in mini_cards:
		card.deselect()
	mini_card.select()
	
func _on_mini_card_mouse_exited(mini_card : Card) -> void:
	mini_card.deselect()

func _on_mini_card_free(mini_card : Card) -> void:
	attack_button.visible = false
	mini_cards.erase(mini_card)
	mini_equipped = null
	player.queue("base_idle")

func _on_spam_timer_timeout() -> void:
	attack_button.disabled = false

#endregion

# Weapons
#-------------------------------------------------------------------------------
#region

## After weapon is used and must be uneqipped
func _on_weapon_weapon_used(_weapon : Weapon) -> void:
	if mini_cards.all(func(n : Card) -> bool: return n.used):
		attacks = 0
		# Resolves combat with defend
		curr_weapon.resolve_combat(player, hp, attacks, enemies)
	else:
		mini_equipped.used = true
		mini_equipped.play("used")
		curr_weapon = null
		equip_mini_card(null, true)
	
## After weapon is used and combat cycle restarts
func _on_weapon_combat_fin(_weapon : Weapon) -> void:
	attacks = Globals.attacks
	actions = Globals.actions
	weapons_display.display_weapon(curr_weapon, mini_equipped, actions)
	for mini_card : Card in mini_cards:
		mini_card.play("RESET")
		mini_card.used = false
		

func _on_weapon_crit() -> void:
	print("CRIT!")
	print("Insert joker effect")

#endregion

func _on_enemy_freed(enemy : Enemy) -> void:
	enemies.erase(enemy)
	if enemies.is_empty():
		spawn_enemy(3)
	else:
		align_enemies()
