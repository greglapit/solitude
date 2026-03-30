class_name ItemIcon
extends Node2D

@onready var sprite2d : Sprite2D = $Sprite2D

var item : Item

func _ready() -> void:
	sprite2d.texture = item.texture
