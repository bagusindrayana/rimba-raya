extends Resource
class_name DataMap

@export var point:int = 1000
@export var structures:Array[DataStructure]


func add_point(p:int):
	point += p
	if point > 1000:
		point = 1000
