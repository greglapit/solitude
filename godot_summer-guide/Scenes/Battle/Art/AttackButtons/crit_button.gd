extends TextureButton

@onready var crit_stored1 : Sprite2D = $CritStored
@onready var crit_stored2 : Sprite2D = $CritStored2
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func spawn(vis : bool = true) -> void:
	if vis and !self.visible:
		animation_player.play("spawn")
	elif !vis and self.visible:
		animation_player.play("despawn")

func update_crits_stored(amt : int) -> void:
	var sprites : Array[Sprite2D] = [crit_stored1,crit_stored2]
	for i : int in range(sprites.size()):
		if i in range(amt - 1):
			sprites[i].visible = true
		else:
			sprites[i].visible = false

func enable(status : bool = true) -> void:
	disabled = !status
	var sprites : Array[Sprite2D] = [crit_stored1,crit_stored2]
	for sprite : Sprite2D in sprites:
		if status:
			sprite.frame = 0
		else:
			sprite.frame = 1

func _ready() -> void:
	visible = false
	spawn(false)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "spawn":
		animation_player.play("RESET")
