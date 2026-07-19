extends Node3D

@export var object_scenes: Array[PackedScene]

@export var total_objects: int = 20

@export var grid_size: float = 1

var grid_data = {} 

var directions = [
	Vector2i(0, -1), # Belakang (Z -)
	Vector2i(0, 1),  # Depan (Z +)
	Vector2i(-1, 0), # Kiri (X -)
	Vector2i(1, 0)   # Kanan (X +)
]

func _ready():
	randomize() 
	
	if object_scenes.size() > 0:
		generate_contiguous_placement(total_objects) 

func generate_contiguous_placement(amount: int):
	if amount <= 0 or object_scenes.size() == 0:
		return

	var start_pos = Vector2i(0, 0)
	place_object(start_pos)

	for i in range(1, amount):
		var placed = false
		
		while not placed:
			var existing_positions = grid_data.keys()
			var random_existing_pos = existing_positions[randi() % existing_positions.size()]
			
			directions.shuffle()
			
			for dir in directions:
				var neighbor_pos = random_existing_pos + dir
				
				if not grid_data.has(neighbor_pos):
					place_object(neighbor_pos)
					placed = true
					break 

func place_object(grid_pos: Vector2i):
	var random_scene = object_scenes[randi() % object_scenes.size()]
	var new_object = random_scene.instantiate()
	

	var world_x = grid_pos.x * grid_size
	var world_z = grid_pos.y * grid_size 
	
	new_object.position = Vector3(world_x, 0, world_z)
	
	#random rotate 90 deg
	var random_step = randi() % 4
	var random_angle = random_step * 90
	
	new_object.rotation.y = deg_to_rad(random_angle)
	
	add_child(new_object)
	
	grid_data[grid_pos] = new_object
