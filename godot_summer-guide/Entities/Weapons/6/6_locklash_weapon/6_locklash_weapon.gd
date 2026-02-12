extends Weapon

var init_dmg : int = 1
var break_dmg : int = 2
var chain_enemy_dict : Dictionary
var chain_chain_effect_dict : Dictionary
var chain_effect_scn : PackedScene
@onready var chain_line_spawner : Node2D = $ChainLineSpawner

func assign_prop() -> void:
	rank = 6
	file_name = "6_locklash_weapon"
	display_name = "Locklash"
	second_name = "Filler Filler Filler"
	description = "-Special: Restrain\n-Cost: 2\n-Bind enemies with %s for one turn, dealing %d. If enemies attack, take %d to get rid of chains." % [display_name, init_dmg, break_dmg]
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
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
	
func break_chain(chain : Line2D, damaging : bool = true) -> void:
	if !chain:
		return
	
	var enemy : Enemy = chain_enemy_dict[chain]
	var temp_chain_effect : AnimatedSprite2D = chain_chain_effect_dict[chain]
	var temp_chain : Line2D = chain
	chain_chain_effect_dict.erase(chain)
	chain_enemy_dict.erase(chain)
	enemy.attack_prevented.disconnect(_on_enemy_attack_prevented)
	if !is_instance_valid(temp_chain_effect):
		chain_enemy_dict.erase(temp_chain)
		chain.queue_free()
		return
		
	if temp_chain:
		chain_enemy_dict.erase(chain)
		temp_chain.queue_free()
	if damaging:
		temp_chain_effect.play("break")
		enemy.damage(break_dmg)
		await temp_chain_effect.tree_exited
		await enemy.animation_player.animation_finished
	else:
		enemy.damage(0)
		temp_chain_effect.play("break")
		await temp_chain_effect.tree_exited
	enemy.chained = false
	
func post_combat() -> void:
	
	# Prevent chain from breaking when special is a reciprocal attack
	if reciprocal_attack:
		return
		
	
	pause.emit(self)
	var temp_dict : Dictionary = chain_enemy_dict  # Editing dict in loop
	for chain : Line2D in temp_dict.keys():
		if chain != temp_dict.keys().back():
			break_chain(chain, false)
		else:
			await break_chain(chain, false)
	resume.emit(self)
	
func _ready() -> void:
	super()
	chain_effect_scn = load("res://Entities/Weapons/ArtWeaponEffects/chained.tscn")

func _on_player_special_impact() -> void:
	if !active:
		return
	for enemy : Enemy in enemies:
		# Skip enemies with chain attached
		if enemy in chain_enemy_dict.values():
			return
			
		# Spawn chains and damage
		var chain : Line2D= chain_line_spawner.add_chain(player.global_position, enemy.global_position)
		chain_enemy_dict[chain] = enemy
		chain.z_index = enemy.z_index + 1
		var chain_effect : AnimatedSprite2D = chain_effect_scn.instantiate()
		chain_effect.scale = Vector2(0.4, 0.4)
		chain_chain_effect_dict[chain] = chain_effect
		enemy.collision_shape.add_child(chain_effect)
		enemy.damage(init_dmg)
		
		# Disable enemy attack and connect signal
		enemy.chained = true
		enemy.attack_prevented.connect(_on_enemy_attack_prevented)

func _process(_delta: float) -> void:
	
	var temp_chains : Array = chain_enemy_dict.keys()
	for chain : Line2D in temp_chains:
		if chain_enemy_dict[chain] == null or chain_enemy_dict[chain].is_dead:
			break_chain(chain, false)
			continue
		
		chain.set_point_position(0, chain_enemy_dict[chain].collision_shape.global_position)

func _on_enemy_attack_prevented(enemy : Enemy) -> void:
	if enemy.chained and !player.animation_player.current_animation.contains("attack"):
		pause.emit(self)
		enemy.play("struggle_chain")
		await enemy.animation_player.animation_finished
		var chain : Line2D = chain_enemy_dict.find_key(enemy)
		await break_chain(chain)
		resume.emit(self)
		
		# Continues combat
		_on_player_anim_finished("defend")

func _on_enemy_freed(_enemy : Enemy) -> void:
	super(_enemy)
	if _enemy == enemies[0]:
		reciprocal_attack = false
		post_combat()
