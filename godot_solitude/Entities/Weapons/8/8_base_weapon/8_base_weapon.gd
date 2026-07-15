extends Weapon

@onready var weapons_effects2 : Sprite2D = $WeaponEffects2

func _on_player_weap_effect_start() -> void:
	animation_player.play("upward_slash")
