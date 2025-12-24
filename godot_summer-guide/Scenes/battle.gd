extends Node2D

@onready var player : Node2D = $Player
@onready var mini_card_positions : Control = $UI/MiniCardPositions

var mini_pos : Array				# Mini Card Positions
var mini_cards : Array[Card]		# Stores drawn card nodes
var mini_equipped : Card				# Current card player has equipped
var curr_weapon : Weapon
var player_weapons : Array[Weapon]

# === Custom Methods ===========================================================
## Loads all player weapons into scene
func load_armory() -> void:
	for i : int in range(len(Globals.armory)):
		var weapon_name : String = Globals.armory[i]
		
		var scene : PackedScene = load("res://Entities/Weapons/%d/%s.tscn" % [i+1,weapon_name])
		var weapon : Weapon = scene.instantiate()
		add_child(weapon)
		weapon.name = weapon_name
		
		player_weapons.append(weapon)
		

func draw_card(amount : int = 1) -> void:
	for i : int in range(amount):
		var mini_card : Card = Card.new_random_card(range(1,11))
		add_child(mini_card)
		mini_card.name = "MiniCard"
		mini_cards.append(mini_card)
		mini_card.input_event.connect(_on_mini_card_input_event.bind(mini_card))
		mini_card.mouse_entered.connect(_on_mini_card_mouse_entered.bind(mini_card))
		mini_card.mouse_exited.connect(_on_mini_card_mouse_exited.bind(mini_card))
		mini_card.free.connect(_on_mini_card_free)
		
	return

func align_mini_cards() -> void:
	for i : int in range(mini_cards.size()):
		mini_cards[i].global_position = mini_card_positions.get_mini_pos()[i]

func equip_mini_card(mini_card : Card) -> void:
	if mini_equipped:
		mini_equipped.visible = true
		mini_cards.append(mini_equipped)
	mini_equipped = mini_card
	mini_cards.erase(mini_equipped)
	mini_equipped.visible = false
	align_mini_cards()
	


# === Built In =================================================================

func _ready() -> void:
	load_armory()
	draw_card(5)
	
	# Runs after first frame
	await get_tree().process_frame
	align_mini_cards() # Running after first frame to wait for control position nodes to position themselves

	
func _input(event: InputEvent) -> void:
	
	# Case for clicking on nothing
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		for card : Card in mini_cards:
			card.deselect()
			curr_weapon = null
			player.play("base_idle")
		
	if event.is_action_pressed("quit_game"):
		get_tree().quit()

# === Signals ==================================================================

# Mini Cards
#-------------------------------------------------------------------------------
func _on_mini_card_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, mini_card : Card) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		curr_weapon =  player_weapons[mini_card.rank - 1]
		player.play(str(mini_card.rank) + "_idle")
		equip_mini_card(mini_card)

func _on_mini_card_mouse_entered(mini_card : Card) -> void:
	for card : Card in mini_cards:
		card.deselect()
	mini_card.select()
	
func _on_mini_card_mouse_exited(mini_card : Card) -> void:
	mini_card.deselect()


func _on_mini_card_free(mini_card : Card) -> void:
	mini_cards.erase(mini_card)
	
