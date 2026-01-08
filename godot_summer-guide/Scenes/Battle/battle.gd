extends Node2D

@onready var player : Node2D = $Player
@onready var weapons_display : Control = $UI/WeaponDisplay
@onready var attack_button : TextureButton = $UI/PanelContainer/AttackButton
@onready var spam_timer : Timer = $SpamTimer

var mini_pos : Array								# Mini Card Positions
var armory_position : Vector2 = Vector2(250,335)
var mini_cards : Array[Card]						# Stores drawn card nodes
var mini_equipped : Card							# Current card player has equipped
var curr_weapon : Weapon							# String name of player weapon
var player_weapons : Array[Weapon]
var actions : int = 1								# Actions player has left

# === Custom Methods ===========================================================
## Loads all player weapons into scene
func load_armory() -> void:
	for i : int in range(Globals.armory.size()):
		var weapon_name : String = Globals.armory[i]
		
		var scene : PackedScene = load("res://Entities/Weapons/%d/%s.tscn" % [i+1,weapon_name])
		var weapon : Weapon = scene.instantiate()
		add_child(weapon)
		weapon.name = weapon_name
		
		player_weapons.append(weapon)

func load_weapons_display() -> void:
	weapons_display.drawn.connect(_on_draw_button_pressed)
	weapons_display.weapon_box_click.connect(_on_weapon_box_click)
	weapons_display.cut.connect(_on_cut_button_pressed)
	weapons_display.polish.connect(_on_polish_button_pressed)
	weapons_display.weapon_display_update.connect(_on_weapon_display_update)


# Mini Cards
#-------------------------------------------------------------------------------
func draw_card(amount : int = 1) -> void:
	var available_slots : int = Globals.max_draw - mini_cards.size()
	amount = min(amount, available_slots)
	
	for i : int in range(amount):
		var mini_card : Card = Card.new_random_card(Globals.available_ranks)
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
		mini_cards[i].z_index = 0
		if tweening:
			var tween : Tween = create_tween()
			tween.tween_property(mini_cards[i], "position", positions[i], 0.3)\
			 .set_trans(Tween.TRANS_SINE)\
			 .set_ease(Tween.EASE_OUT)
		else:
			mini_cards[i].global_position = positions[i]

func equip_mini_card(mini_card : Card = null, visual_update : bool = true) -> void:
	if mini_card:
		curr_weapon =  player_weapons[mini_card.rank - 1]
		
		mini_card.play("equip")
		if mini_equipped and mini_equipped != mini_card:
			mini_equipped.position = mini_card.position + Vector2(30,0)
			mini_equipped.visible = true
		mini_cards.append(mini_equipped)
		mini_equipped = mini_card
		mini_cards.erase(mini_equipped)
		
	else:
		curr_weapon =  null
		
		if mini_equipped:
			mini_equipped.position = armory_position + (Vector2(30,0) * mini_cards.size())
			mini_equipped.visible = true
			mini_equipped.play("spawn")
			mini_cards.append(mini_equipped)
			mini_equipped = null
		player.queue("base_idle")
		
	mini_cards = mini_cards.filter(func(e : Card) -> bool: return e != null)		# Remove Null values
	weapons_display.displayed_weapon = curr_weapon
	weapons_display.card = mini_equipped
	
	if visual_update:
		weapons_display.display_weapon(curr_weapon, mini_equipped)
		if mini_equipped:
			player.queue(str(mini_equipped.rank) + "_base_idle")
		else:
			player.play("base_idle")
	
	align_mini_cards()


# === Built In =================================================================

func _ready() -> void:
	load_armory()
	load_weapons_display()
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
		dragged_card.z_index = 1
		dragged_card.position = get_global_mouse_position()

# === Signals ==================================================================
# UI
#-------------------------------------------------------------------------------
func _on_weapon_box_click() -> void:
	equip_mini_card(null)
	
func _on_draw_button_pressed() -> void:
	if mini_cards.size() >= Globals.max_draw:
		return
	draw_card(Globals.draw_amt)
	spam_timer.wait_time = 6.5
	spam_timer.start()
	weapons_display.play("joker_open_mouth")

func _on_cut_button_pressed() -> void:
	var cut : bool = mini_equipped.cut()
	if !cut:
		return
	equip_mini_card(mini_equipped)
	weapons_display.timeout_buttons()

func _on_polish_button_pressed() -> void:
	var polished : bool = mini_equipped.polish()
	if !polished:
		return
	equip_mini_card(mini_equipped)
	weapons_display.timeout_buttons()

func _on_attack_button_pressed() -> void:
	attack_button.disabled = true
	if !spam_timer.is_stopped():
		return
	player.play(str(mini_equipped.rank) + "_base_attack")
	mini_equipped.damage()
	equip_mini_card(mini_equipped)
	spam_timer.wait_time = 1.0
	spam_timer.start()
	
func _on_weapon_display_update() -> void:
	align_mini_cards()
	if mini_equipped:
		player.play(str(mini_equipped.rank) + "_base_idle")
		attack_button.visible = true
	else:
		player.play("base_idle")
		attack_button.visible = false

# Mini Cards
#-------------------------------------------------------------------------------

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
				spam_timer.wait_time = 1.0
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
	if dragging:
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
	pass # Replace with function body.
