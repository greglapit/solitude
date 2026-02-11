extends Weapon

var init_dmg : int = 1
var chain_enemy_dict : Dictionary
var chain_effect_scn : PackedScene
@onready var chain_line_spawner : Node2D = $ChainLineSpawner

func assign_prop() -> void:
	rank = 6
	file_name = "6_locklash_weapon"
	display_name = "Locklash"
	second_name = "Filler Filler Filler"
	description = "-Special: Restrain\n-Cost: 2\n-Bind enemies with Locklash, dealing %d damage." % [init_dmg]
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/6/6_locklash_weapon.png")
	player_idle_anim = "6_locklash_idle"
	player_attack_anim = "6_locklash_attack"
	player_defend_anim = "6_locklash_defend"
	player_special_anim = "6_locklash_special"
	has_special = true
	special_cost = 2

func has_valid_spec_target(_enemies : Array) -> bool:
	for enemy : Enemy in _enemies:
		if !enemy in chain_enemy_dict.values():
			return true
	return false

func _ready() -> void:
	super()
	chain_effect_scn = load("res://Entities/Weapons/ArtWeaponEffects/chained.tscn")

func _on_player_special_impact() -> void:
	if !active:
		return
	chain_line_spawner.z_index = enemies[0].z_index + 1
	for enemy : Enemy in enemies:
		if enemy in chain_enemy_dict.values():
			return
		var chain : Line2D= chain_line_spawner.add_chain(player.global_position, enemy.global_position)
		chain_enemy_dict[chain] = enemy
		var chain_effect : AnimatedSprite2D = chain_effect_scn.instantiate()
		chain_effect.scale = Vector2(0.4, 0.4)
		enemy.add_child(chain_effect)
		enemy.damage(init_dmg)

func _process(_delta: float) -> void:
	for chain : Line2D in chain_enemy_dict.keys():
		if chain_enemy_dict[chain] == null or chain_enemy_dict[chain].is_dead:
			chain_enemy_dict.erase(chain)
			chain.queue_free()
			continue
		
		chain.set_point_position(0, chain_enemy_dict[chain].collision_shape.global_position)
