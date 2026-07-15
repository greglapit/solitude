class_name Item
extends Resource

var id : String = resource_path.get_file().trim_suffix('.tres')
@export var name : String
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
