extends TextureButton

@onready var crit_stored1 : Sprite2D = $CritStored
@onready var crit_stored2 : Sprite2D = $CritStored2
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func spawn(vis : bool = true) -> void:
	if vis and animation_player.current_animation != "RESET":
		animation_player.play("spawn")
	elif !vis and self.visible:
		animation_player.play("despawn")

func update_crit_stored(amt : int) -> void:
	var sprites : Array[Sprite2D] = [crit_stored1,crit_stored2]
	for i : int in range(sprites.size()):
		if i in range(amt - 1):
			sprites[i].frame = 0
		else:
			sprites[i].frame = 1

func _ready() -> void:
	visible = false
	spawn(false)
	
	
	var sprites : Array[Sprite2D] = [crit_stored1,crit_stored2]
	for i : int in range(sprites.size()):
		if i in range(Globals.max_crits - 1):
			sprites[i].visible = true
		else:
			sprites[i].visible = false

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "spawn":
		animation_player.play("RESET")
