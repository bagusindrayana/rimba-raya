extends Node3D

class_name CameraController

@export_category("Camera Settings")
@export var inital_zoom: float = 10.0
@export var min_zoom: float = 10.0
@export var max_zoom: float = 80.0
@export var move_speed: float = 20.0

@export_category("Features")
@export var can_orbit: bool = false:
	set(value):
		can_orbit = value
		if not can_orbit and is_inside_tree():
			camera_rotation.x = initial_pitch
@export var edge_pan_enabled: bool = true 
@export var edge_pan_margin: float = 20.0

var camera_position: Vector3
var camera_rotation: Vector3
var zoom: float = 20.0 # 30 = Standard zoom level, in meters
var initial_pitch: float

@onready var camera = $Camera

func _ready():
	zoom = inital_zoom
	camera_rotation = rotation_degrees # Initial rotation
	initial_pitch = rotation_degrees.x
	can_orbit = false

func _process(delta):
	position = position.lerp(camera_position, delta * 8)
	rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	
	# Smoothly update zoom
	camera.position = camera.position.lerp(Vector3(0, 0, zoom), delta * 8)
	
	handle_input(delta)
	

# Handle input
func handle_input(delta):
	var input := Vector3.ZERO
	
	# 1. Keyboard Input
	input.x = Input.get_axis("camera_left", "camera_right")
	input.z = Input.get_axis("camera_forward", "camera_back")
	
	# 2. Screen Edge Panning (Mouse melewati tepi layar)
	if edge_pan_enabled:
		var viewport_size = get_viewport().get_visible_rect().size
		var mouse_pos = get_viewport().get_mouse_position()
		
		# Cek tepi X (Kiri / Kanan)
		if mouse_pos.x < edge_pan_margin:
			input.x -= 1.0
		elif mouse_pos.x > viewport_size.x - edge_pan_margin:
			input.x += 1.0
			
		# Cek tepi Y (Atas / Bawah layar, yang mana adalah sumbu Z di 3D)
		if mouse_pos.y < edge_pan_margin:
			input.z -= 1.0
		elif mouse_pos.y > viewport_size.y - edge_pan_margin:
			input.z += 1.0

	if input != Vector3.ZERO:
		input = input.rotated(Vector3.UP, rotation.y).normalized()
		# Menggunakan delta agar pergerakan mulus di semua frame rate
		camera_position += input * move_speed * delta 
	
	# Zoom in/out
	
	if Input.is_action_just_released("zoom_in"):
		zoom = max(min_zoom, zoom - 5)
		
	if Input.is_action_just_released("zoom_out"):
		zoom = min(max_zoom, zoom + 5)
	
	# Back to center
	
	if Input.is_action_pressed("camera_center"):
		camera_position = Vector3.ZERO

func _input(event):
	# Rotate camera using mouse (hold 'middle' mouse button)
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_rotate"):
			
			camera_rotation.y += -event.relative.x / 10.0
			
			if can_orbit:
				camera_rotation.x += -event.relative.y / 10.0
				camera_rotation.x = clamp(camera_rotation.x, -89.0, -10.0)
