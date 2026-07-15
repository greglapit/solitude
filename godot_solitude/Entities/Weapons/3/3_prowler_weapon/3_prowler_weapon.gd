extends Weapon

var turn_clock : Node2D

func equip() -> void:
	super()
	var ui_nodes : Array = get_tree().get_nodes_in_group("UI")
	var turn_clocks : Array = ui_nodes.filter(func(n : Node) -> bool: return n.name == "TurnClock")
	turn_clock = null if turn_clocks.is_empty() else turn_clocks[0]
	
	if !turn_clock:
		push_error("Cannot assign turn_clock")
		
	enemies[0].prowled = true
	
	turn_clock.show_turn(turn_clock.turn.PROWLER_BUSH)
	turn_clock.locked = true
	
func unequip() -> void:
	super()
	enemies[0].prowled = false
	
	turn_clock.locked = false

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("stab")
