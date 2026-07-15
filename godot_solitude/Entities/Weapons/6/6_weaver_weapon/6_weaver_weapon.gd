extends Weapon

var webbed_enemies_effect_dict : Dictionary # Dictionary. Enemy keys, web effect values.
var webbed_effect_scn  : PackedScene
@onready var chain_line_spawner : Node2D = $ChainLineSpawner


func has_valid_spec_target(_enemies : Array) -> bool:
	for enemy : Enemy in _enemies:
		if !enemy in webbed_enemies_effect_dict.keys():
			return true
	return false

func _ready() -> void:
	super()
	webbed_effect_scn = load("res://Entities/Weapons/ArtWeaponEffects/webbed.tscn")

func _on_player_special_impact() -> void:
	if !active:
		return
	for enemy : Enemy in enemies:
		# Skip enemies with chain attached
		if enemy in webbed_enemies_effect_dict.keys():
			return
			
		# Spawn chains and damage
		var chain : Line2D= chain_line_spawner.add_chain(player.global_position, enemy.global_position)
		chain.z_index = enemy.z_index + 1
		var chain_effect : AnimatedSprite2D = webbed_effect_scn.instantiate()
		enemy.collision_shape.add_child(chain_effect)
		enemy.webbed = true
		enemy.play("shake")
		webbed_enemies_effect_dict[enemy] = chain_effect
		
		await get_tree().create_timer(0.2).timeout
		chain.queue_free()
		
func _on_enemy_attack_impact(enemy : Enemy) -> void:
	super(enemy)
	if enemy in webbed_enemies_effect_dict.keys():
		enemy.slowed = false
		webbed_enemies_effect_dict[enemy].queue_free()
		webbed_enemies_effect_dict.erase(enemy)
