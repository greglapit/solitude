extends Node

var health : int = 100
var draw_amt : int = 1
var max_draw : int = 5			# How many items player can have drawn at a time
var available_ranks : Array = [1,2,3,4,5,6,7,8,9,10]
var armory : Array[String] = ['1_base_weapon', '2_base_weapon', '3_base_weapon', '4_base_weapon', '5_base_weapon', \
					'6_base_weapon', '7_base_weapon', '8_base_weapon', '9_base_weapon', '10_base_weapon']

var armory_durs : Array = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]

#var armory : Array = ['1BaseWeapon', '2BaseWeapon', '3BaseWeapon', '4BaseWeapon', '5BaseWeapon', '6BaseWeapon', '7BaseWeapon', '8BaseWeapon', '9BaseWeapon','10BaseWeapon']
