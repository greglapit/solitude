extends Item

@export var rank : int:
	set(value):
		id = "concentrate" + str(rank)
		name = Globals.ranks[rank] + " Concentrate"
		rank = value
