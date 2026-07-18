extends Node3D
class_name TreeGrow
@export var variant_trees : Array[PackedScene]
@export var variant_bushs : Array[PackedScene]
@export var tree_object : Node3D
@export var min_scale : Vector3 = Vector3.ONE * 0.5
@export var max_scale : Vector3  = Vector3.ONE
@export var grow_speed : float = 5

var can_grow = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if variant_trees.size() > 0:
		var variant = variant_trees.pick_random().instantiate()
		tree_object.add_child(variant)
		
	if !tree_object or !can_grow:
		pass
	tree_object.scale = min_scale
	
	
	# spawn effect
	#var tween = create_tween()
	#scale = Vector3.ONE * 0.5
	#tween.tween_property(self, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	spawn_bush()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !tree_object or !can_grow:
		pass
	var tween = create_tween()
	tween.tween_property(tree_object, "scale", max_scale + (Vector3.ONE * randf_range(-0.1, 0.3)), grow_speed)
	# tree_object.scale = tree_object.scale.lerp(max_scale,grow_speed * delta)

func spawn_bush():
	
	for i in 6:
		var random_x: float = randf_range(-0.3, 0.3)
		var random_z: float = randf_range(-0.3, 0.3)
		var variant = variant_bushs.pick_random().instantiate()
		self.add_child(variant)
		variant.global_position = global_position + Vector3(random_x,0,random_z)
	pass
	
