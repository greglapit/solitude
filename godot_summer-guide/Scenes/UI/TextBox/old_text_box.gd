#class_name TextBox
#extends CanvasLayer
#
#@onready var label : Label = $PanelContainer/MarginContainer/Label
#@onready var animation_player : AnimationPlayer = $AnimationPlayer
#
#const text_box_scn : PackedScene = preload("res://Common/UI/Text Box/text_box.tscn")
#
#var print_started : bool = true
#var text : String = "Whose woods these are I think I know. His house is in the village though. He will not see me stopping here to watch his woods fill up with snow. Whose woods these are I think I know. His house is in the village though. He will not see me stopping here to watch his woods fill up with snow."
#var font : Font = load("res://Common/BitPotionExt.ttf")
#var done_printing : bool = false
#var force_finish : bool = false
#var paragraph : TextParagraph = TextParagraph.new()
#
#
## === Custom Methods ===========================================================
#
#static func generate(txt : String) -> TextBox:
	#var node : TextBox = text_box_scn.instantiate()
	#node.text = txt
	#
	#return node
#
#func start_print() -> void:
	#
	#var lines : Array
	#for i : int in paragraph.get_line_count():
		#var _range : Vector2i = paragraph.get_line_range(i)
		#lines.append(text.substr(_range.x, _range.y - _range.x))
	#
	#for line : String in lines:
		#for i : int in line.length():
			#label.text += line[i]
			#if force_finish:
				#label.text = text
				#done_printing = true
				#return
			#await get_tree().process_frame
		#label.text += "\n"
	#
	#done_printing = true
#
#
## === Built In =================================================================
#
#func _ready() -> void:
	#label.text = ""
	#
	## Maps out text into separate lines to avoid word shooting to next line as writing
	#paragraph.add_string(text, font, 16)
	#paragraph.width = label.custom_minimum_size.x
	#paragraph.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	#
#func _input(_event: InputEvent) -> void:
	#if _event.is_pressed():
		#if done_printing:
			#animation_player.play("fade_out")
			#await animation_player.animation_finished
			#queue_free()
		#else:
			#force_finish = true
			#
#
## === Signals ==================================================================
