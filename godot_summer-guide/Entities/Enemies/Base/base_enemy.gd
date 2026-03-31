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
const enemy_scn : PackedScene = preload("res://Entities/Enemies/Base/base_enemy.tscn")

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

# Status Effect Logic
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

# OBSOLETE. No longer allowing saving during battle
#region
#func save() -> Dictionary:
	#var data : Dictionary = {
	#"attack_disabled": attack_disabled,
	#"chained": chained,
	#"class_name": "Enemy",
	#"filename": get_scene_file_path(),
	#"kneeling": kneeling,
	#"name": name,
	#"parent": get_parent().get_path(),
	#"pos_x": position.x,
	#"pos_y": position.y,
	#"prowled": prowled,
	#"rank": rank,
	#"slowed": slowed,
	#"starting_anim": starting_anim,
	#"suit": suit,
	#"true_rank": true_rank,
	#"webbed": webbed,
	#"z_index": z_index
	#}
#
	#return data

#endregion

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


func status_logic_update() -> void:
	if chained or kneeling: # add other attack disabling HERE
		attack_disabled = true
	else:
		attack_disabled = false
		
	if webbed or prowled: # add other slows HERE
		slowed = true
	else:
		slowed = false

func generate_loot() -> Dictionary:
	var drops : Dictionary = {}
	var loot_table : LootTable = load("res://Entities/Enemies/Base/base_enemy_loot_table.tres")
	
	for loot : Loot in loot_table.table:
		if randf() <= loot.drop_chance:
			var amount : int = loot.get_amount() # or randi_range(min, max)
			if drops.has(loot.item):
				drops[loot.item.id] += amount
			else:
				drops[loot.item.id] = amount
	return drops

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
	if _anim_name == "death":
		freed.emit(self)
		queue_free()
	
	if attack_disabled or slowed:
		animation_player.play("hindered_idle")
	else:
		animation_player.play("idle")
