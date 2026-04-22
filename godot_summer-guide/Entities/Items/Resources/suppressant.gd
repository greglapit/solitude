extends Item

@export var rank : int:
	set(value):
		id = "suppressant" + str(rank)
		name = Globals.ranks[rank] + " Suppressant"
		rank = value
