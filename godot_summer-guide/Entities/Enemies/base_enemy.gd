class_name Enemy
extends Area2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var card_sprite : Sprite2D = $CollisionShape2D/CardSprite
@onready var suit_sprite : Sprite2D = $CollisionShape2D/SuitSprite
@onready var label1 : Label = $CollisionShape2D/Label
@onready var label2 : Label = $CollisionShape2D/Label2
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var status_label : Label = $CollisionShape2D/Status/Label
@onready var status_animation_player : AnimationPlayer = $CollisionShape2D/Status/AnimationPlayer2

# Node References
var player : Node2D
const enemy_scn : PackedScene = preload("res://Entities/Enemies/base_enemy.tscn")

# Stats
var rank : int = -1:	# The effective hp
	set(value):
		rank_update.emit(value)
		rank = value
var true_rank : int 	# The rank the enemy spawned with and uses abilities based off of
var suit : Card.Suits = Card.Suits.HEART
var is_dead : bool = false

# Status Effects
var chained : bool = false:		# Locklash
	set(value):
		chained = value
		status_logic_update()
var webbed : bool = false:		# Weaver
	set(value):
		webbed = value
		status_logic_update()
var prowled : bool = false:		# Prowler
	set(value):
		prowled = value
		status_logic_update()
var kneeling : bool = false:	# Cmd
	set(value):
		kneeling = value
		status_logic_update()

# Status Effect Logic. Updated in _process
var attack_disabled : bool = false
var slowed : bool = false
var starting_anim : String = "spawn"

signal rank_update(new : int)
@warning_ignore("unused_signal")
signal attack_impact
signal attack_prevented()
signal damaged(amt : int)
signal freed(enemy : Enemy)

# === Custom Methods ===========================================================
func save() -> Dictionary:
	var data : Dictionary = {
		"name" : name,
		"class_name" : get_script().get_global_name(),
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"z_index" : z_index,
		"starting_anim" : animation_player.current_animation
	}
	
	# Loop through all script variables
	var script : GDScript = get_script()
	for prop : Dictionary in script.get_script_property_list():
		# Skip functions and constants; keep only variables
		if prop["type"] != TYPE_CALLABLE and prop["type"] != TYPE_OBJECT:
			data[prop["name"]] = get(prop["name"])
			
	#for prop_dict : Dictionary in get_property_list():
		#var prop_name : String = prop_dict.name
		#var usage : PropertyUsageFlags = prop_dict.usage
		#
		#if usage and PROPERTY_USAGE_STORAGE:
			#data[prop_dict.name] = get(prop_name)
		
	return data


static func new_enemy(_suit : Card.Suits, _ranks : Array) -> Enemy:
	var _rank : int = _ranks.pick_random()
	if _suit not in Card.Suits.values() or _rank not in range(1,14):
		print("Invalid enemy declaration")
		return
	var enemy : Enemy = enemy_scn.instantiate()
	enemy.suit = _suit
	enemy.rank = _rank
	enemy.true_rank = _rank
	return enemy

func update_labels() -> void:
	label1.text = Globals.ranks[rank]
	label2.text = Globals.ranks[rank]

## Damage the enemy
func damage(amt : int) -> int:
	rank  = max(rank-amt, 0)
	damaged.emit(amt)
	if rank <= 0:
		is_dead = true
		play("death")
	else:
		play("shake")
	update_labels()
	
	return amt

## Damage the player
func attack(_weapon : Weapon, _combat_data : Dictionary) -> Dictionary:
	var combat_data : Dictionary = _combat_data
	
	if attack_disabled:
		attack_prevented.emit()
		return combat_data
	
	if rank <= 0:
		combat_data["hp_delta"] = rank
		return combat_data
	play("attack")
	combat_data["hp_delta"] = -rank
	return combat_data

func play(anim : String = "RESET") -> void:
	animation_player.stop()
	animation_player.play(anim)

func display_bleed(duration : int) -> void:
	status_label.text = str(duration)
	if duration > 0:
		status_animation_player.play("bleeding")
	else:
		status_animation_player.play("RESET")

@warning_ignore("unused_parameter")
func emit_freed(card : Enemy = self) -> void:
	freed.emit(self)

func status_logic_update() -> void:
	if chained or kneeling: # add other attack disabling HERE
		attack_disabled = true
	else:
		attack_disabled = false
		
	if webbed or prowled: # add other slows HERE
		slowed = true
	else:
		slowed = false

# === Built In =================================================================

func _ready() -> void:
	var suit_name : String = str(Card.Suits.keys()[suit]).to_lower() + "s" + ".png"
	var suit_art_path : String = "res://Entities/Enemies/Base/Art/"
	suit_sprite.texture = load(suit_art_path + suit_name)
	card_sprite.frame = randi() % 4
	suit_sprite.frame = randi() % 4
	name = "Enemy" + str(get_tree().get_node_count_in_group("enemies"))
	
	update_labels()
	
	play("spawn")
	await animation_player.animation_finished
	if starting_anim != "spawn":
		play(starting_anim)
		
	
func _input(_event: InputEvent) -> void:
	pass

func _process(_delta: float) -> void:
	pass

# === Signals ==================================================================


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if attack_disabled or slowed:
		animation_player.play("hindered_idle")
	else:
		animation_player.play("idle")
