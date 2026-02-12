extends Weapon

var turn_clock : Node2D

func assign_prop() -> void:
	rank = 3
	file_name = "3_prowler_weapon"
	display_name = "Prowler"
	second_name = "Low Rank Hunter"
	description = "-Special: None\n-Passive: Initiate unseen, always attacking first.\n"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "3_prowler_idle"
	player_attack_anim = "3_prowler_attack"
	player_defend_anim = "3_prowler_defend"
	has_special = false
	
	var ui_nodes : Array = get_tree().get_nodes_in_group("UI")
	var turn_clocks : Array = ui_nodes.filter(func(n : Node) -> bool: return n.name == "TurnClock")
	turn_clock = null if turn_clocks.is_empty() else turn_clocks[0]
	
	if !turn_clock:
		push_error("Cannot assign turn_clock")

func equip() -> void:
	super()
	turn_clock.show_turn(turn_clock.turn.PROWLER_BUSH)
	turn_clock.locked = true
	
func unequip() -> void:
	turn_clock.locked = false

# Always Attacks first
func resolve_combat(_player : Node2D, _mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	player = _player
	mini_equipped = _mini_card
	hp = _hp
	attacks = _attacks
	enemies = _enemy_array
	critting = false
	reciprocal_attack = false
	combat_data = {
	"hp_delta" = 0,
	"durability_delta" = 0,
	}
	
	# Visuals
	if active and enemies[0]:
		weapon_effects.position = enemies[0].position
		weapon_effects.z_index = enemies[0].z_index + 5
	
	# Combat order calculations
	# Player has no attacks left, enemy attacks
	if _attacks <= 0:
		combat_data= enemies[0].attack(self, combat_data)
		return combat_data
	
	combat_data["durability_delta"] = -1
	
	# Player has attacks left
	if using_special:
		player.play(player_special_anim)
	else:
		player.play(player_attack_anim)
	return combat_data

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("stab")
