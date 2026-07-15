class_name ChooseEncounter
extends Node2DScene

@onready var encounter_frames : Node2D = $EncounterFrames
@onready var middle_frame_marker : Marker2D = $EncounterFrames/MiddleFrameMarker
@onready var middle_tree_cover : Sprite2D = $Background/MiddleTreeCover
@onready var middle_trail : Sprite2D = $Background/MiddleTrail
@onready var left_frame_marker : Marker2D = $EncounterFrames/LeftFrameMarker
@onready var left_trail : Sprite2D = $Background/LeftTrail
@onready var left_tree_cover : Sprite2D = $Background/LeftTreeCover
@onready var right_frame_marker : Marker2D = $EncounterFrames/RightFrameMarker
@onready var right_trail : Sprite2D = $Background/RightTrail
@onready var right_tree_cover : Sprite2D = $Background/RightTreeCover

var valid_encounters : Array = [Globals.scenes.KOD, Globals.scenes.BATTLE, Globals.scenes.QOD]


const num_paths : int = 3

@onready var scene_group : Dictionary = {
	0 : {
		"marker" : middle_frame_marker,
		"tree_cover" : middle_tree_cover,
		"trail" : middle_trail,
	},
	1 : {
		"marker" : left_frame_marker,
		"tree_cover" : left_tree_cover,
		"trail" : left_trail,
	},
	2 : {
		"marker" : right_frame_marker,
		"tree_cover" : right_tree_cover,
		"trail" : right_trail,
	}
}

# === Custom Methods ===========================================================

func get_encounters() -> Array:
	if !ProgressTracker.force_encounters.is_empty():
		var encs : Array = ProgressTracker.force_encounters.duplicate()
		ProgressTracker.force_encounters.clear()
		return encs
		
	valid_encounters.clear()
	
	# ENCOUNTER CHANCES
	# ==========================================================================
	# Base encounters chance
	var encounter_chance : Dictionary = {
		Globals.scenes.BATTLE : .9,
		Globals.scenes.KOD : .2,
		Globals.scenes.QOD : .2
	}
	
	# Give players higher chance if haven't had nonbattle choices in a while
	for i : int in range(ProgressTracker.forced_battles_in_row):
		for scn : Globals.scenes in encounter_chance:
			if scn != Globals.scenes.BATTLE:
				encounter_chance[scn] = min(1, encounter_chance[scn] + .1)
	
	# Cannot get QOD if already unlocked rank 10
	if ProgressTracker.unlocked_rank == 10:
		encounter_chance[Globals.scenes.QOD] = 0
		
	# Cannot get KOD if no available weapons
	if Globals.available_weapon_pool.is_empty():
		encounter_chance[Globals.scenes.KOD] = 0
		
	# No special encounters twice in a row
	if ProgressTracker.last_encounter != Globals.scenes.BATTLE:
		encounter_chance[ProgressTracker.last_encounter] = 0
	
	# ==========================================================================
	
	# Choose Encounters
	var encounters : Array = []
	for encounter : Globals.scenes in encounter_chance.keys():
		if encounters.size() >= 3:
			break
		
		if randf() <= encounter_chance[encounter]:
			encounters.append(encounter)
	
	# Defaults to battle if special encounters not chosen
	if encounters.is_empty():
		encounters.append(Globals.scenes.BATTLE)
	
	if encounters.size() == 1 and encounters[0] == Globals.scenes.BATTLE:
		ProgressTracker.forced_battles_in_row += 1
	
	return encounters


# === Built In =================================================================

func _ready() -> void:
	# Decide valid encounters
	
	var rand_path_order : Array = range(num_paths)
	rand_path_order.shuffle()
	
	var encounters : Array = get_encounters()
	
	var chosen_paths : Array = rand_path_order.slice(0,encounters.size())
	
	for i : int in chosen_paths.size():
		var group : Dictionary = scene_group[chosen_paths[i]]
		
		group["tree_cover"].hide()
		group["trail"].show()
		
		var new_frame : EncounterFrame = EncounterFrame.new_frame(encounters[i])
		new_frame.position = group["marker"].position
		new_frame.clicked.connect(_on_frame_clicked.bind(new_frame))
		encounter_frames.add_child(new_frame)
		
	# Visualize available encounters
	
	

# === Signals ==================================================================

func _on_frame_clicked(frame : EncounterFrame) -> void:
	var scn : Globals.scenes = frame.scn
	ProgressTracker.last_encounter = scn
	change_scn.emit(scn, false, false)
	pass
