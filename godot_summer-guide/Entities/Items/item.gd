class_name Item
extends Resource

@export var name : String
@export var id : String
@export var texture : AtlasTexture
@export var type : item_type = item_type.NORMAL
@export var max_count : int = 9999
@export_multiline  var description : String

enum item_type {
	NORMAL,			
	CONSUMABLE,		# Health pots, etc.
	CURRENCY,		# Tatters, etc
	UNIQUE,			# Player can only hold one
}
