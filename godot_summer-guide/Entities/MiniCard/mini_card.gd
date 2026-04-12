class_name MiniCard
extends Area2D

# Logic
enum Suits {
	DIAMOND,
	HEART,
	SPADE,
	CLUB
}
var rank : int = -1
var suit : Suits = Suits.DIAMOND
var selected : bool = false
var durability : int
var used : bool = false:
	set(value):
		if value:
			play("used")
		else:
			play("RESET")
		used = value

# Visuals
const card_scn : PackedScene = preload("res://Entities/MiniCard/mini_card.tscn")
var red : Color = Color.html("#b33831")
var black : Color = Color.html("#2e222f")
var sprite_variant : int = -1

signal damaged
signal free

@onready var sprite2d : Sprite2D = $CollisionShape2D/Sprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var label1 : Label = $CollisionShape2D/Labels/Label
@onready var label2 : Label = $CollisionShape2D/Labels/Label2


# === Custom Methods ===========================================================
#func save() -> Dictionary:
	#var data : Dictionary = {
		#"class_name" : "MiniCard",
		#"durability": durability,
		#"parent": get_parent().get_path(),
		#"pos_x": position.x,
		#"pos_y": position.y,
		#"sprite_variant": sprite_variant,
		#"suit": suit,
		#"used": used,
	#}
	#return data
	#
	
static func new_card(_suit : Suits, _rank : int) -> MiniCard:
	if _suit not in Suits.values() or _rank not in range(1,14):
		print("Invalid card declaration")
		return
	var card : MiniCard = card_scn.instantiate()
	card.suit = _suit
	card.rank = _rank
	return card

## Returns random card with optional range for rank and suit
static func new_random_card(_range : Array = range(1,14), suit1 : int = -1, suit2 : int = -1, suit3 : int = -1, suit4 : int = -1) -> MiniCard:
	
	var card : MiniCard = card_scn.instantiate()
	var suits : Array[int] = [suit1, suit2, suit3, suit4]
	
	var no_suit_constraint : bool = suits.all(func(e : int) -> bool: return e == -1)
	if no_suit_constraint:
		card.suit = randi() % 4 as Suits
	else:
		var suit_count : int= 0
		var suit_choices : Array[int]= []
		for _suit : int in suits:
			if _suit != -1:
				suit_choices.append(_suit)
				suit_count += 1
		card.suit = suit_choices[randi() % suit_count] as Suits
	
	card.rank = _range.pick_random()
	return card

func set_rank(_rank : int) -> void:
	rank = _rank
	
func set_suit(_suit : Suits) -> void:
	suit = _suit

func select() -> void:
	selected = true
	animation_player.queue("selected")
	return
	
func deselect() -> void:
	selected = false
	if animation_player.current_animation == "selected":		# Prevents overwriting of animation
		animation_player.play("RESET")							# if player stops hovering
	return

func damage(amount : int = 1) -> void:
	damaged.emit()
	durability -= amount
	if durability <= 0:
		free.emit(self)
		animation_player.play("break")
		await animation_player.animation_finished
		queue_free()

## Returns true if successful
func cut(amount : int = 1) -> bool:
	if durability <= 1 or not Globals.armory.keys().has(rank - amount):
		animation_player.play("shake")
		return false
		
	damage()
	rank -= amount
	update_visuals()
	return true
	
## Returns true if successful
func socket(amount : int = 1) -> bool:
	if durability <= 1 or not Globals.armory.keys().has(rank + amount):
		animation_player.play("shake")
		return false
	damage()
	rank += amount
	update_visuals()
	return true
	
func update_visuals() -> void:
	# Frames for card variant are stored every 4. Math to account for this animation
	sprite2d.frame = sprite_variant + (4 * clamp(5 - durability, 0, 6))
	label1.text = Globals.ranks[rank]
	label2.text = Globals.ranks[rank]

func play(anim : String, reverse : bool = false) -> void:
	if reverse:
		animation_player.play_backwards(anim)
	else:
		animation_player.play(anim)

func queue(anim : String) -> void:
	animation_player.queue(anim)
# === Built In =================================================================

func _ready() -> void:
	name = "MiniMiniCard" + str(get_tree().get_node_count_in_group("mini_cards"))
	# Assigns random edge texture
	sprite2d.frame = randi() % 4
	sprite_variant = sprite2d.frame
	animation_player.play("spawn")
	update_visuals()
	
	durability = Globals.armory_durs[rank + 1]
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "RESET" and anim_name != "used":
		animation_player.play("RESET")
