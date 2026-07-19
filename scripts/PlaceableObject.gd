extends Node3D
class_name PlaceableObject
@export var variant_objects : Array[PackedScene]
@export var object_count : int = 1
@onready var place_object : Node3D = $object_place

var variant_object_index : int = 0

var builder_controller : BuilderController
var structure : Structure

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_object()
	
	

func give_reward():
	if builder_controller and structure and structure.reward_point > 0:
		builder_controller.show_reward(self.global_position,structure.reward_point)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func update_object():
	for child in place_object.get_children():
		child.queue_free()
	if variant_objects.size() > 0:
		if object_count > 1:
			for i in object_count:
				var random_x: float = randf_range(-0.3, 0.3)
				var random_z: float = randf_range(-0.3, 0.3)
				
				variant_object_index = randi_range(0,variant_objects.size()-1)
				var variant = variant_objects[variant_object_index].instantiate()
				place_object.add_child(variant)
				variant.global_position = global_position + Vector3(random_x,0,random_z)
				
		else:
			variant_object_index = randi_range(0,variant_objects.size()-1)
			var variant = variant_objects[variant_object_index].instantiate()
			place_object.add_child(variant)
