extends Node

var health : int = 100
var draw_amt : int = 1
var actions : int = 1
var attacks : int = 1
var max_draw : int = 1			# How many items player can have drawn at a time
var available_ranks : Array = [2]#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
var armory : Dictionary = {2: '2_base_weapon'}# {1: '1_base_weapon', 2: '2_base_weapon', 3: '3_base_weapon', \
							#4: '4_base_weapon', 5: '5_base_weapon', 6: '6_base_weapon', \
							#7: '7_base_weapon', 8: '8_base_weapon', 9: '9_base_weapon', 10: \
							#'10_base_weapon'}
							
var armory_durs : Array = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
