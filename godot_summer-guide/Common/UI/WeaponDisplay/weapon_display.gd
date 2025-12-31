extends Control

@onready var joker : Sprite2D = $Joker
@onready var mouth_label : Label = $Joker/MouthLabel
@onready var card_label1 : Label = $Joker/CardLabel
@onready var card_label2 : Label = $Joker/CardLabel2
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var weapon_name_label : Label = $HBoxContainer/PanelContainer/VBoxContainer/NameBanner/WeaponName
@onready var weapon_box : PanelContainer = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer
@onready var tick1 : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Tick1
@onready var tick2 : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Tick2
@onready var tick3 : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Tick3
@onready var tick4 : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Tick4
@onready var tick5 : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Tick5
@onready var tick6 : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Tick6
@onready var tick7 : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/HBoxContainer/Tick7
@onready var weapon_art : TextureRect = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/WeaponArt
@onready var draw_button : TextureButton = $HBoxContainer/PanelContainer/VBoxContainer/PanelContainer/CenterContainer/DrawButton
@onready var cut_button : TextureButton = $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/CutButton
@onready var polish_button : TextureButton = $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/PolishButton
@onready var click_timer : Timer = $ClickTimer

var displayed_weapon : Weapon
var card : Card
var art_path : String = "res://Common/UI/WeaponDisplay/Art/Weapons/"
var weapon_arts : Array[Resource]
var ticks : Array[TextureRect] 

signal drawn
signal weapon_box_click
signal cut
signal polish
signal change_display 	# Sent when Weapons display should update name and weapon banner

# === Custom Methods ===========================================================
## Updates weapon display's weapon and card objects. Puts weapon arts and name
func display_weapon(weapon : Weapon = null, mini_card : Card = null) -> void:
	if weapon and mini_card:
		weapon_name_label.text = weapon.display_name
		weapon_art.texture = weapon_arts[weapon.rank - 1]
		draw_button.visible = false
		cut_button.disabled = false
		polish_button.disabled = false
		show_ticks(mini_card.durability)
	else:
		weapon_name_label.text = ""
		weapon_art.texture = load("res://Common/UI/WeaponDisplay/Art/Main/weapon_art_filler.png")
		draw_button.visible = true
		cut_button.disabled = true
		polish_button.disabled = true
		show_ticks()
	
func timeout_buttons(time : float = 0.5) -> void:
	draw_button.disabled = true
	cut_button.disabled = true
	polish_button.disabled = true
	click_timer.wait_time = time
	click_timer.start()

func show_ticks(num : int = 0) -> void:
	for tick : int in range(ticks.size()):
		if tick in range(num):
			ticks[tick].visible = true
		else:
			ticks[tick].visible = false

func play(anim : String = "RESET") -> void:
	animation_player.play(anim)

# === Built In =================================================================

func _ready() -> void:
	ticks = [tick1,tick2,tick3,tick4,tick5,tick6,tick7]
	for i : int in Globals.armory.size():
		weapon_arts.append(load(art_path + str(i + 1) + "/" + Globals.armory[i] + ".png"))
	display_weapon()
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_center_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		weapon_box_click.emit()
		cut_button.disabled = true
		polish_button.disabled = true

func _on_draw_button_pressed() -> void:
	if click_timer.is_stopped():
		drawn.emit()
		timeout_buttons(6)

func _on_cut_button_pressed() -> void:
	if click_timer.is_stopped():
		cut.emit()
		click_timer.start()

func _on_polish_button_pressed() -> void:
	if click_timer.is_stopped():
		polish.emit()
		click_timer.start()

func _on_click_timer_timeout() -> void:
	draw_button.disabled = false
	if displayed_weapon:
		cut_button.disabled = false
		polish_button.disabled = false
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "joker_spinning":
		mouth_label.text = str(card.ranks[card.rank])
		card_label1.text = str(card.ranks[card.rank])
		card_label2.text = str(card.ranks[card.rank])
		animation_player.play("joker_end_spin")

func _on_change_display() -> void:
	display_weapon(displayed_weapon, card)
