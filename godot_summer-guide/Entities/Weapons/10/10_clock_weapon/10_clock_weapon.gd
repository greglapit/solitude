extends Weapon

@onready var warp_effect : Sprite2D = $WarpEffect
@onready var animation_player_2 : AnimationPlayer = $WarpEffect/AnimationPlayer

func equip() -> void:
	super()
	description = "-Special: Trick Room\n-Cost: %d\n-Reverse turn order while holding \
					the %s. Larger numbers attack first. Use to reverse back." \
					% [special_cost, display_name]

func special_attack() -> Dictionary:
	var dict : Dictionary = super()
	warp_effect.global_position = player.global_position + Vector2(0,-30)
	return dict

func post_combat() -> void:
	update_node_refs()
	var holding_weapon : bool = false
	for mini_card : Card in mini_cards:
		if mini_card.rank == 10:
			holding_weapon = true
	
	if !holding_weapon and turn_order_flipped:
		battle_node.turn_order_flipped = false

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if !using_special:
		animation_player.play("shockwave")

func _on_player_special_impact() -> void:
	if !active:
		return
	animation_player_2.play("shockwave")
	reciprocal_attack = false
	battle_node.turn_order_flipped = !battle_node.turn_order_flipped
