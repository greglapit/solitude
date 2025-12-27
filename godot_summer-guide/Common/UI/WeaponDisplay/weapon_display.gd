extends Control

@onready var weapon_name_label : Label = $HBoxContainer/PanelContainer/VBoxContainer/NameBanner/WeaponName
@onready var weapon_art : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/WeaponArt
@onready var draw_button : TextureButton = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/CenterContainer/DrawButton
@onready var cut_button : TextureButton = $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/CutButton
@onready var polish_button : TextureButton = $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/PolishButton

signal drawn
signal cut
signal polish

# === Custom Methods ===========================================================


# === Built In =================================================================

func _ready() -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_draw_button_pressed() -> void:
	drawn.emit()


func _on_cut_button_pressed() -> void:
	cut.emit()


func _on_polish_button_pressed() -> void:
	polish.emit()
