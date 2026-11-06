extends Node2D

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var scream_effect : CPUParticles2D = $ScreamEffect
@onready var label : Label = $Label
@onready var AP : AnimationPlayer = $AnimationPlayer

var scream_counter : int = 3
var starting_health : int = 50

signal anim_finished(anim)

func scream():
	scream_effect.emitting = true
	animated_sprite.play("scream")

func combat():
	scream_counter -= 1
	if scream_counter <= 0:
		scream()
		scream_counter = 3

func damage():
	AP.play("delayed_damaged")

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animated_sprite_animation_finished)
	AP.animation_finished.connect(_on_AP_animation_finished)
	animated_sprite.play("spawn")
	label.visible = false

func _on_animated_sprite_animation_finished():
	anim_finished.emit(animated_sprite.animation)
	match animated_sprite.animation:
		"spawn":
			scream()
			label.visible = true
		_:
			animated_sprite.play("idle")

func _on_AP_animation_finished(anim : String):
	anim_finished.emit(anim)
