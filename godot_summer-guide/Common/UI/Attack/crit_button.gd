extends TextureButton

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func spawn(vis : bool = true) -> void:
	if vis and animation_player.current_animation != "RESET":
		animation_player.play("spawn")
	elif !vis and self.visible:
		animation_player.play("despawn")

func _ready() -> void:
	visible = false
	spawn(false)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "spawn":
		animation_player.play("RESET")
