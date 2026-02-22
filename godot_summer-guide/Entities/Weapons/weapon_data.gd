class_name WeaponData
extends Resource

@export var rank : int = -1
@export var file_name : String
@export var display_name : String
@export var second_name : String
@export_multiline var description : String
@export_multiline var lore : String = "Example made up lore. filler filler. This weapon was used by made up figure back when madeup event happend. Etc. Etc."
@export var display_texture : Resource
@export var has_special : bool = false
@export var special_cost : int = 1
@export var int1 : int
@export var int2 : int
@export var int3 : int



# Player/Enemy info
@export var player_idle_anim : String
@export var player_attack_anim : String
@export var player_defend_anim : String
@export var player_special_anim : String
