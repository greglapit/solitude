extends Node

var hp : int = 20
var max_hp : int = 20
var draw_amt : int = 3
var actions : int = 1
var attacks : int = 1
var max_draw : int = 3			# How many items player can have drawn at a time
var max_crits : int = 3
var armory : Dictionary = {10: '10_clock_weapon'}
var available_ranks : Array = armory.keys()
var ranks : Array = ["0","A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var armory_durs : Array = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]

var all_weapons : Dictionary = {
	'1_base_weapon' : 1, '1_philo_weapon' : 1, '1_seed_weapon' : 1, \
	'2_base_weapon' : 2, '2_twin_weapon' : 2, '2_glass_weapon' : 2, \
	'3_base_weapon' : 3, '3_trident_weapon' : 3, '3_prowler_weapon' : 3, \
	'4_base_weapon' : 4, '4_mirra_weapon' : 4, '4_bastion_weapon' : 4,\
	'5_base_weapon' : 5, '5_claw_weapon' : 5, '5_maw_weapon' : 5,\
	'6_base_weapon' : 6, '6_locklash_weapon' : 6, '6_weaver_weapon' : 6,\
	'7_base_weapon' : 7, '7_vamp_weapon' : 7, '7_severance_weapon' : 7,\
	'8_base_weapon' : 8, '8_splitter_weapon' : 8, '8_cata_weapon' : 8,\
	'9_base_weapon' : 9, '9_cloud_weapon' : 9, '9_cmd_weapon' : 9,\
	'10_base_weapon' : 10, \
}
