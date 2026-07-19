extends Node3D
class_name WaterPond

@export var animals_prefabs : Array[PackedScene]
var builder_controller : BuilderController
var structure : Structure

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func place():
	give_reward()
	if builder_controller:
		var list_neighbors : Array[Vector2] = builder_controller.get_occupied_around(Vector2i(global_position.x,global_position.z),1)
		var time_wait = 10 - min(9,list_neighbors.size())
		await get_tree().create_timer(time_wait).timeout
		var animal = animals_prefabs.pick_random().instantiate()
		add_child(animal)
		(animal as AnimalWild).water_pond = self
		(animal as AnimalWild).init_animal()
		animal.global_position = Vector3(global_position.x,0,global_position.z)

func give_reward():
	if !builder_controller:
		return
	builder_controller.show_reward(self.global_position,structure.reward_point)
