extends Node3D
class_name BuilderController
@export var canvas_layer: CanvasLayer
@export var reward_indicator: PackedScene
@export var  cell_size : int = 1
@export var structures: Array[Structure] = []
var data_structures:Array[DataStructure] = []


var map:DataMap

var current_index : int = -1
var index:int = 0 # Index of structure being built

@export var selector:Node3D # The 'cursor'
@export var selector_container:Node3D # Node that holds a preview of the structure
@export var view_camera:Camera3D # Used for raycasting mouse
#@export var gridmap:GridMap
@export var point_indicator_control : Control
@export var point_indicator: ColorRect

var preview_structure : Node3D

var plane:Plane # Used for raycasting mouse

var current_pos : Vector3

func _ready():
	
	map = DataMap.new()
	plane = Plane(Vector3.UP, Vector3.ZERO)
	
	# Create new MeshLibrary dynamically, can also be done in the editor
	# See: https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html
	
	#var mesh_library = MeshLibrary.new()
	#
	#for structure in structures:
		#
		#var id = mesh_library.get_last_unused_item_id()
		#
		#mesh_library.create_item(id)
		#mesh_library.set_item_mesh(id, get_mesh(structure.model))
		#mesh_library.set_item_mesh_transform(id, Transform3D())
		#
	#gridmap.mesh_library = mesh_library
	
	update_structure()
	update_point()

func _process(delta):
	
	# Controls
	
	action_rotate() # Rotates selection 90 degrees
	action_structure_toggle() # Toggles between structures
	
	#action_save() # Saving
	#action_load() # Loading
	#action_load_resources() # Loading from resources
	
	# Map position based on mouse
	
	var world_position = plane.intersects_ray(
		view_camera.project_ray_origin(get_viewport().get_mouse_position()),
		view_camera.project_ray_normal(get_viewport().get_mouse_position()))

	var gridmap_position = Vector3(round(world_position.x), 0, round(world_position.z))
	#if gridmap_position == Vector3.ZERO:
		#return
	selector.position = lerp(selector.position, gridmap_position, min(delta * 40, 1.0))
	
	if current_pos != gridmap_position:
		current_pos = gridmap_position
		update_structure()
	
	action_build(gridmap_position)
	action_demolish(gridmap_position)

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#if event.relative != Vector2.ZERO:
			#update_structure()

# Retrieve the mesh from a PackedScene, used for dynamically creating a MeshLibrary
func get_mesh(packed_scene):
	var scene_state:SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if(scene_state.get_node_type(i) == "MeshInstance3D"):
			for j in scene_state.get_node_property_count(i):
				var prop_name = scene_state.get_node_property_name(i, j)
				if prop_name == "mesh":
					var prop_value = scene_state.get_node_property_value(i, j)
					
					return prop_value.duplicate()

# Build (place) a structure

func action_build(gridmap_position):
	if Input.is_action_just_pressed("build") and !check_occupied_data_structures(Vector2i(gridmap_position.x,gridmap_position.z)):
		#var structure = structures[index]
		#var instance = structure.model.instantiate()
		if !preview_structure:
			return
		var instance = preview_structure
		instance.reparent(self)
		preview_structure = null
		if instance is TreeGrow:
			var tg : TreeGrow = (instance as TreeGrow)
			tg.can_grow = true
			tg.builder_controller = self
			
			tg.grow_tree()
		instance.global_position = gridmap_position
		instance.rotation  = selector.rotation
		
		# spawn effect
		var tween = create_tween()
		instance.scale = Vector3.ONE * 0.5
		tween.tween_property(instance, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		var ds = DataStructure.new()
		ds.position = Vector2i(gridmap_position.x,gridmap_position.z)
		ds.structure = index
		data_structures.append(ds)
		
		map.point -= structures[index].point
		update_point()
		
		#await get_tree().create_timer(1.0).timeout
		#update_structure()
		
		pass
		#var previous_tile = gridmap.get_cell_item(gridmap_position)
		#gridmap.set_cell_item(gridmap_position, index, gridmap.get_orthogonal_index_from_basis(selector.basis))
		
		#if previous_tile != index:
			#map.point -= structures[index].point
			#update_point()
			
			#Audio.play("sounds/placement-a.ogg, sounds/placement-b.ogg, sounds/placement-c.ogg, sounds/placement-d.ogg", -20)

# Demolish (remove) a structure

func action_demolish(gridmap_position):
	if Input.is_action_just_pressed("demolish"):
		pass
		#if gridmap.get_cell_item(gridmap_position) != -1:
			#gridmap.set_cell_item(gridmap_position, -1)
			
			#Audio.play("sounds/removal-a.ogg, sounds/removal-b.ogg, sounds/removal-c.ogg, sounds/removal-d.ogg", -20)

# Rotates the 'cursor' 90 degrees

func action_rotate():
	if Input.is_action_just_pressed("rotate"):
		selector.rotate_y(deg_to_rad(90))
		
		#Audio.play("sounds/rotate.ogg", -30)

# Toggle between structures to build

func action_structure_toggle():
	if Input.is_action_just_pressed("structure_next"):
		index = wrap(index + 1, 0, structures.size())
		if preview_structure:
			preview_structure.queue_free()
			preview_structure = null
		update_structure()
		#Audio.play("sounds/toggle.ogg", -30)
	
	if Input.is_action_just_pressed("structure_previous"):
		index = wrap(index - 1, 0, structures.size())
		if preview_structure:
			preview_structure.queue_free()
			preview_structure = null
		update_structure()
		#Audio.play("sounds/toggle.ogg", -30)

	

# Update the structure visual in the 'cursor'

func update_structure():
	if current_index == index:
		if preview_structure and preview_structure is TreeGrow:
			(preview_structure as TreeGrow).update_tree()

	
	if !preview_structure:
		#preview_structure.queue_free()
		var structure = structures[index]
		current_index = index
		var instance = structure.model.instantiate()
		if instance is TreeGrow:
			var tg : TreeGrow = (instance as TreeGrow)
			tg.can_grow = false
			tg.builder_controller = self
		preview_structure = instance
		selector.add_child(preview_structure)
	## Clear previous structure preview in selector
	#for n in selector_container.get_children():
		#selector_container.remove_child(n)
		#n.queue_free()
		#
	## Create new structure preview in selector
	#var _model = structures[index].model.instantiate()
	#selector_container.add_child(_model)
	#_model.position.y += 0.25
	
func update_point():
	if point_indicator:
		point_indicator.size.x = ((map.point/1000.0) * 200) - 6
		print(map.point)

func show_reward(tree_pos:Vector3):
	if reward_indicator:
		var ri = reward_indicator.instantiate()
		canvas_layer.add_child(ri)
		
		ri.position = get_viewport().get_camera_3d().unproject_position(tree_pos) - (ri.size / 2.0)
		var original_scale = ri.scale
		ri.scale = ri.scale * 0.5
		var tween = create_tween()
		tween.tween_property(ri, "scale", original_scale, 0.7)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT).set_delay(0.5)
		
		tween.tween_property(ri, "position", point_indicator_control.global_position + (point_indicator_control.size / 2.0), 1)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT).set_delay(0.5)
		
		tween.tween_callback(_point_indicator_control_effect)

var tween_point_indicator_control_effect : Tween
func _point_indicator_control_effect():
	if tween_point_indicator_control_effect and tween_point_indicator_control_effect.is_valid():
		tween_point_indicator_control_effect.kill()
	point_indicator_control.scale = Vector2.ONE * 1.5
	
	tween_point_indicator_control_effect = create_tween()
	tween_point_indicator_control_effect.tween_property(point_indicator_control, "scale",Vector2.ONE, 0.7)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_ease(Tween.EASE_OUT)

# Saving/load

#func action_save():
	#if Input.is_action_just_pressed("save"):
		#print("Saving map...")
		#
		#map.structures.clear()
		#for cell in gridmap.get_used_cells():
			#
			#var data_structure:DataStructure = DataStructure.new()
			#
			#data_structure.position = Vector2i(cell.x, cell.z)
			#data_structure.orientation = gridmap.get_cell_item_orientation(cell)
			#data_structure.structure = gridmap.get_cell_item(cell)
			#
			#map.structures.append(data_structure)
			#
		#ResourceSaver.save(map, "user://map.res")
	#
#func action_load():
	#if Input.is_action_just_pressed("load"):
		#print("Loading map...")
		#
		#gridmap.clear()
		#
		#map = ResourceLoader.load("user://map.res")
		#if not map:
			#map = DataMap.new()
		#for cell in map.structures:
			#gridmap.set_cell_item(Vector3i(cell.position.x, 0, cell.position.y), cell.structure, cell.orientation)
			#
		#update_point()
#
#func action_load_resources():
	#if Input.is_action_just_pressed("load_resources"):
		#print("Loading map...")
		#
		#gridmap.clear()
		#
		#map = ResourceLoader.load("res://sample map/map.res")
		#if not map:
			#map = DataMap.new()
		#for cell in map.structures:
			#gridmap.set_cell_item(Vector3i(cell.position.x, 0, cell.position.y), cell.structure, cell.orientation)
			#
		#update_point()

func position_snapped(pos: Vector2):
	return (pos / cell_size).floor() * cell_size
	
func check_occupied_data_structures(pos:Vector2i)->bool:
	for ds in data_structures:
		if ds.position == pos:
			return true
	return false
