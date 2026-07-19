extends Node3D
class_name AnimalWild

@export var wander_interval_time : float = 10.0
@export var y_offset : float = 0.0
@export var flying : bool = false
@export var icon_texture : Texture2D
@export var animal_icon_prefab : PackedScene
@export var animation_player : AnimationPlayer

var water_pond : WaterPond
var move_to_next_grid = false
var current_grid : Vector3
var current_icon : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_grid = global_position
	start_wander()
	

func init_animal():
	if water_pond and water_pond.builder_controller:
		var icon = animal_icon_prefab.instantiate()
		#print("spawn icon")
		water_pond.builder_controller.canvas_layer.add_child(icon)
		
		if icon_texture:
			var ict = icon.find_child("IconTexture",true)
			if ict:
				(ict as TextureRect).texture = icon_texture
		var btn = icon.find_child("Button",true)
		if btn:
			(btn as Button).pressed.connect(self.take_reward)
		
		icon.scale = Vector2.ONE * 0.5
		var tween = create_tween()
		tween.tween_property(icon, "scale", Vector2.ONE, 0.7)\
		.set_trans(Tween.TRANS_SPRING)\
		.set_ease(Tween.EASE_OUT)
		current_icon = (icon as Control)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_icon:
		current_icon.position = get_viewport().get_camera_3d().unproject_position(global_position) - (current_icon.size / 2.0)


func  start_wander():
	if animation_player:
		animation_player.play("idle")
	var wander_next_grid_timer = Timer.new()
	wander_next_grid_timer.wait_time = wander_interval_time
	wander_next_grid_timer.autostart = true
	wander_next_grid_timer.timeout.connect(_on_wander_next_grid_timeout)
	add_child(wander_next_grid_timer)

	if !flying:
		var wander_timer = Timer.new()
		wander_timer.wait_time = wander_interval_time / 4
		wander_timer.autostart = true
		wander_timer.timeout.connect(_on_wander_timeout)
		add_child(wander_timer)

func _on_wander_next_grid_timeout():
	
	
	if water_pond == null:
		return
	move_to_next_grid = true
	if animation_player:
		animation_player.play("walk")
	var list_targets : Array[Vector2] = water_pond.builder_controller.get_occupied_around(Vector2i(water_pond.global_position.x,water_pond.global_position.z),1)
	var next_target : Vector2
	if list_targets.size() > 0:
		next_target  = list_targets.pick_random()
	else:
		next_target = Vector2(water_pond.global_position.x,water_pond.global_position.z)
	if flying:
		var grid_target = water_pond.builder_controller.get_occupied_data_object(Vector2i(next_target.x,next_target.y)).find_child("tree_place",true)
		var trees : Array[Node] = []
		if grid_target:
			trees = grid_target.get_children()
			
		if trees.size() <= 0:
			return
			
			
		var next_tree = trees.pick_random()
		#print(next_tree.name)
		
		
		var random_surface_tree = get_random_point_on_aabb_surface(next_tree)
		var dest = Vector3(next_tree.global_position.x,max(random_surface_tree.y,y_offset),next_tree.global_position.z)
		
		if dest != global_position:
			current_grid = dest
			look_at(dest)
			rotate_y(PI)
			var tween = create_tween()
			tween.tween_property(self, "global_position", dest, next_target.distance_to(Vector2(global_position.x,global_position.z)) * 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
			tween.tween_callback(func():
				move_to_next_grid = false
			)
		else:
			move_to_next_grid = false
	else:
		
		var dest = Vector3(next_target.x,0,next_target.y)
		if dest != global_position:
			current_grid = dest
			look_at(dest)
			rotate_y(PI)
			var tween = create_tween()
			tween.tween_property(self, "global_position", dest, next_target.distance_to(Vector2(global_position.x,global_position.z)) * 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
			tween.tween_callback(func():
				move_to_next_grid = false
				if animation_player:
					animation_player.play("idle")
			)
		else:
			move_to_next_grid = false

func _on_wander_timeout():
	if water_pond == null or move_to_next_grid:
		return
	if animation_player:
		animation_player.play("walk")
	var tween = create_tween()
	var dest = Vector3(current_grid.x - randf_range(0.0,0.5),0,current_grid.y - randf_range(0.0,0.5))
	look_at(dest)
	rotate_y(PI)
	tween.tween_property(self, "global_position", dest, 1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		if animation_player:
			animation_player.play("idle")
	)

func get_random_point_on_aabb_surface(object_node : Node3D)-> Vector3:
	var point = Vector3()
	
	var mesh_node : MeshInstance3D
	for c in  object_node.get_children():
		if c is MeshInstance3D:
			mesh_node = c as MeshInstance3D
	if !mesh_node:
		return point
	return get_random_surface_point(mesh_node,y_offset)
	#var aabb = mesh_node.mesh.get_aabb()
	#var min_pos = aabb.position
	#var max_pos = aabb.position + aabb.size 
	#
	#
	#var axis = randi() % 3
	#
	#var is_max = randi() % 2 == 0
	#
	#if axis == 0:
		## left right
		#point.x = max_pos.x if is_max else min_pos.x
		##point.y = randf_range(min_pos.y, max_pos.y) + y_offset
		#point.z = randf_range(min_pos.z, max_pos.z) + y_offset
	#elif axis == 1:
		## top bottom
		#point.x = randf_range(min_pos.x, max_pos.x) + y_offset
		#point.y = max_pos.y if is_max else min_pos.y
		#point.z = randf_range(min_pos.z, max_pos.z) + y_offset
	#elif axis == 1:
		##front or back
		#point.x = randf_range(min_pos.x, max_pos.x) + y_offset
		##point.y = randf_range(min_pos.y, max_pos.y) + y_offset
		#point.y = randf_range(max_pos.y, max_pos.y + y_offset)
		#point.z = max_pos.z if is_max else min_pos.z
		#
	#return point
	
	
func get_random_surface_point(mesh_instance: MeshInstance3D, min_y_offset: float) -> Vector3:
	var mesh = mesh_instance.mesh
	if not mesh:
		push_error("MeshInstance3D tidak memiliki mesh!")
		return Vector3.ZERO

	# Dapatkan semua titik (vertices) yang membentuk segitiga permukaan
	var faces = mesh.get_faces() 
	var valid_triangles = []
	var total_area = 0.0

	# Loop setiap 3 vertex (karena 1 segitiga = 3 sudut)
	for i in range(0, faces.size(), 3):
		var a = faces[i]
		var b = faces[i+1]
		var c = faces[i+2]

		# Cek apakah segitiga menyentuh atau berada di atas offset Y
		if a.y >= min_y_offset or b.y >= min_y_offset or c.y >= min_y_offset:
			# Hitung luas segitiga untuk pembobotan
			var area = ((b - a).cross(c - a)).length() * 0.5
			
			valid_triangles.append({
				"a": a, "b": b, "c": c, "area": area
			})
			total_area += area

	# Jika tidak ada permukaan di atas offset tersebut
	if valid_triangles.is_empty():
		push_warning("Tidak ada permukaan mesh di atas Y offset: ", min_y_offset)
		return mesh_instance.global_position # Mengembalikan titik tengah objek sebagai fallback

	# Pilih segitiga secara acak, dengan pembobotan luas area
	var random_area_picker = randf() * total_area
	var current_area = 0.0
	var selected_triangle = null

	for tri in valid_triangles:
		current_area += tri.area
		if current_area >= random_area_picker:
			selected_triangle = tri
			break
			
	# Jaga-jaga jika ada kesalahan presisi float
	if selected_triangle == null:
		selected_triangle = valid_triangles[-1]

	# Hasilkan titik acak di dalam segitiga tersebut (Barycentric Coordinates)
	var r1 = sqrt(randf())
	var r2 = randf()
	
	var local_point = (1.0 - r1) * selected_triangle.a + \
					  (r1 * (1.0 - r2)) * selected_triangle.b + \
					  (r1 * r2) * selected_triangle.c

	# Karena sebagian sudut segitiga mungkin berada di bawah offset, 
	# kita pastikan titik akhirnya benar-benar di atas batas.
	if local_point.y < min_y_offset:
		# Jika meleset, rekursif panggil ulang fungsinya sampai dapat (Retry)
		return get_random_surface_point(mesh_instance, min_y_offset)

	# Ubah posisi dari lokal ke global berdasarkan rotasi, skala, dan posisi MeshInstance
	var global_point = mesh_instance.global_transform * local_point
	return global_point

func take_reward():
	if water_pond and water_pond.builder_controller:
		water_pond.builder_controller.show_reward(water_pond.global_position,water_pond.structure.reward_point)
	current_icon.queue_free()
	current_icon = null
