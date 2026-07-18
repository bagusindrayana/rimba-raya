extends Node3D
class_name TreeGrow
@export var variant_trees : Array[PackedScene]
@export var variant_bushs : Array[PackedScene]

@export var min_scale : Vector3 = Vector3.ONE * 0.5
@export var max_scale : Vector3  = Vector3.ONE
@export var grow_speed : float = 5

@onready var tree_object : Node3D = $tree_place
@onready var bush_object : Node3D = $bush_place

var can_grow = true
var builder_controller : BuilderController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	update_tree()
	
	if !tree_object or can_grow == false:
		scale = Vector3.ONE
		return
	grow_tree()

func grow_tree():
	tree_object.scale = min_scale
	
	
	# spawn effect
	#var tween = create_tween()
	#scale = Vector3.ONE * 0.5
	#tween.tween_property(self, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	var tween = create_tween()
	tween.tween_property(tree_object, "scale", max_scale + (Vector3.ONE * randf_range(-0.1, 0.3)), randf_range(grow_speed,grow_speed+5))
	tween.tween_callback(finish_grow)
func update_tree():
	for child in tree_object.get_children():
		child.queue_free()
	if variant_trees.size() > 0:
		var variant = variant_trees.pick_random().instantiate()
		tree_object.add_child(variant)
	spawn_bush()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !tree_object or can_grow == false:
		return
	
	# tree_object.scale = tree_object.scale.lerp(max_scale,grow_speed * delta)
	
func spawn_bush():
	for child in bush_object.get_children():
		child.queue_free()
	for i in 6:
		var random_x: float = randf_range(-0.3, 0.3)
		var random_z: float = randf_range(-0.3, 0.3)
		var variant = variant_bushs.pick_random().instantiate()
		bush_object.add_child(variant)
		variant.global_position = global_position + Vector3(random_x,0,random_z)
	pass
	
func finish_grow():
	if builder_controller and can_grow:
		builder_controller.map.add_point(20)
		builder_controller.update_point()
		builder_controller.show_reward(self.global_position)
		can_grow = false
		
		# reward effect
		var tween = create_tween()
		scale = Vector3.ONE * 0.5
		tween.tween_property(self, "scale", Vector3.ONE, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
