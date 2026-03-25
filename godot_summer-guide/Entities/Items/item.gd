class_name ItemData
extends Resource

@export var name : String
@export var id : String
@export var texture : AtlasTexture
@export var type : item_type = item_type.NORMAL
@export var max_count : int = 0
@export_multiline  var description : String

enum item_type {
	NORMAL,
	CURRENCY,
	STORY
}
