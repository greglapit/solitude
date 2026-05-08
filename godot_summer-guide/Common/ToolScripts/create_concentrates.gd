# editor_helper.gd
@tool
extends Node

var rank_names : Array = ["Zero", "Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"]

## Size of item sprite in atlas
const ATLAS_REGION_SIZE : Vector2 = Vector2(32,32)

## Concentrate atlas loc
const CONC_LOC : Vector2 = Vector2(0, 96)

## Suppressant atlas loc
const SUP_LOC : Vector2 = Vector2(0,48)

## Atlas File
const item_atlas : CompressedTexture2D = preload("res://Entities/Items/item_atlas.png")

@export var create_concentrates : bool = false:
	set(value):
		if value:
			save_concentrates()
			create_concentrates = false # Reset the button

@export var create_suppressants : bool = false:
	set(value):
		if value:
			save_suppressants()
			create_suppressants = false # Reset the button

func save_concentrates() -> void:
	for i : int in range(1,11):
		var new_data : Item = Item.new()
		new_data.name = rank_names[i] + " Concentrate"
		new_data.id = "concentrate" + str(i)
		new_data.max_count = 10
	

		var tex : AtlasTexture = AtlasTexture.new()
		tex.atlas = item_atlas
		
		var rank_conc_loc : Vector2 = CONC_LOC
		rank_conc_loc += Vector2(ATLAS_REGION_SIZE.x * (i-1), 0)
		tex.region = Rect2(rank_conc_loc, ATLAS_REGION_SIZE)
		
		new_data.texture = tex
		
		print(new_data.texture.region)
		# ResourceSaver is used to write the file to the disk
		var path : String = "res://Entities/Items/Resources/concentrate" + str(i) + ".tres"
		ResourceSaver.save(new_data, path)
		new_data.take_over_path(path)

func save_suppressants() -> void:
	for i : int in range(1,11):
		var new_data : Item = Item.new()
		new_data.name = rank_names[i] + " Suppressant"
		new_data.id = "suppressant" + str(i)
		new_data.max_count = 10
	

		var tex : AtlasTexture = AtlasTexture.new()
		tex.atlas = item_atlas
		
		var rank_conc_loc : Vector2 = SUP_LOC
		rank_conc_loc += Vector2(ATLAS_REGION_SIZE.x * (i-1), 0)
		tex.region = Rect2(rank_conc_loc, ATLAS_REGION_SIZE)
		
		new_data.texture = tex
		
		print(new_data.texture.region)
		# ResourceSaver is used to write the file to the disk
		var path : String = "res://Entities/Items/Resources/suppressant" + str(i) + ".tres"
		ResourceSaver.save(new_data, path)
		new_data.take_over_path(path)
