class_name Card
extends Node2D

enum Suits {
	DIAMOND,
	HEART,
	SPADE,
	CLUB
}

var suit : Suits
var rank : int
var hp : int
var power_incr : int = 0   #Keeps track of suit specific interactions. See *suit*_effect
var is_player_card : bool = false
var is_card_attacking : bool = false
const card_scn : PackedScene = preload("res://Entities/Cards/Scenes/card.tscn")
var red = Color.html("#b33831")
var black = Color.html("#2e222f")
var ranks = ["0","A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

@export var selected : bool = false
@onready var sprite2d : Sprite2D = $Sprite2D
@onready var area2d : Area2D = $Area2D
@onready var AP : AnimationPlayer = $AnimationPlayer
@onready var upper_left_label : Label = $Control/UpperLeftLabel
@onready var lower_right_label : Label = $Control/LowerRightLabel
@onready var health_ticks : Array[Node] = self.find_children("HealthTick?")

signal animation_finished(node, anim)
signal dead(node)

# === Custom Methods ===========================================================

func set_hp(_hp : int):
	hp = _hp
	update_card_visuals()

func set_rank(_rank : int):
	rank = _rank
	update_card_visuals()
	
func set_suit(_suit : Suits):
	suit = _suit
	update_card_visuals()

static func new_card(_suit : Suits, _rank : int) -> Card:
	if _suit not in Suits.values() or _rank not in range(1,14):
		print("Invalid card declaration")
		return
	var card : Card = card_scn.instantiate()
	card.suit = _suit
	card.rank = _rank
	return card

## Returns random card with optional range for rank and suit
static func new_random_card(_range : Array = range(1,14), suit1 : int = -1, suit2 : int = -1, suit3 : int = -1, suit4 : int = -1) -> Card:
	var card : Card = card_scn.instantiate()
	var suits = [suit1, suit2, suit3, suit4]
	if suits.all(func(e): return e == -1):
		card.suit = randi() % 4
	else:
		var suit_count = 0
		var suit_choices = []
		for _suit in suits:
			if _suit != -1:
				suit_choices.append(_suit)
				suit_count += 1
		card.suit = suit_choices[randi() % suit_count]
	# Temp
	card.rank = _range.pick_random()
	return card

func find_card_texture(_suit : int) -> String:
	var file_path = "res://Entities/Cards/Art/bare_" + str(Suits.find_key(_suit)).to_lower() + ".png"
	return file_path

func update_card_visuals():
	# Texture
	var texture = find_card_texture(suit)
	sprite2d.texture =  load(texture)
	
	# Label Colors
	var card_num_res = "res://Entities/Cards/Resources/card_numbers.tres"
	upper_left_label.label_settings = load(card_num_res).duplicate()
	lower_right_label.label_settings = upper_left_label.label_settings
	if suit == Suits.DIAMOND or suit == Suits.HEART:
		upper_left_label.label_settings.font_color = red
	else:
		upper_left_label.label_settings.font_color = black
	
	# Rank
	var card_text : String = ranks[rank]
	upper_left_label.text = card_text
	lower_right_label.text = card_text
	
	# Health Ticks
	if is_player_card:
		for tick in health_ticks:
			tick.visible = true
			var tick_num = int(tick.name.erase(0,10))
			if tick_num >= hp:
				tick.visible = false
	
func select():
	selected = true
	AP.play("selected")

func deselect():
	selected = false
	AP.play("RESET")
	
func chip():
	if rank > 1:
		set_rank(rank - 1)
		AP.play("chip")
		
func sharpen():
	if rank < 14:
		set_rank(rank + 1)
		AP.play("sharpen")

func damage(amount : int = 1):
	set_hp(hp-amount)
	if !is_player_card:
		rank = hp
		AP.play("delayed_chip")

func check_dead():
	if hp < 1:
		dead.emit(self)
		queue_free()
	update_card_visuals()

func AP_play(anim : String):
	AP.play(anim)

func heart_effect():
	if power_incr == 1:
		hp += 1
		rank = hp
		update_card_visuals()
	else:
		upper_left_label.text = str(rank) + "+"
		lower_right_label.text = str(rank) + "+"
		power_incr +=1

# === Built In =================================================================

func _ready() -> void:
	set_hp(rank)
	AP.animation_finished.connect(_on_AP_animation_finished)
	AP.play("spawn_bottom")
	

# === Signals ==================================================================

func _on_AP_animation_finished(anim : String):
	animation_finished.emit(self, anim)
	
	if suit == Suits.HEART && !is_player_card && anim == "delayed_chip":
		heart_effect()
	
