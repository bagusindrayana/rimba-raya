extends Node3D
class_name TreeGrow
@export var is_tree : bool = true
@export var variant_trees : Array[PackedScene]
@export var variant_bushs : Array[PackedScene]

@export var min_scale : Vector3 = Vector3.ONE * 0.5
@export var max_scale : Vector3  = Vector3.ONE
@export var grow_speed : float = 5
#@export var reward_interval: float = 20.0

@onready var tree_object : Node3D = $tree_place
@onready var bush_object : Node3D = $bush_place

var can_grow = true
var builder_controller : BuilderController
var structure : Structure

var variant_tree_index = 0
var variant_bush_indexs : Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	update_tree()
	
	if !tree_object or can_grow == false:
		scale = Vector3.ONE
		return
	grow_tree()

func grow_tree():
	if !is_tree:
		if structure and structure.point > 0:
			builder_controller.show_reward(self.global_position,structure.reward_point)
		return
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
		#var variant = variant_trees.pick_random().instantiate()
		variant_tree_index = randi_range(0,variant_trees.size()-1)
		var variant = variant_trees[variant_tree_index].instantiate()
		tree_object.add_child(variant)
	spawn_bush()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !tree_object or can_grow == false:
		return
	
	# tree_object.scale = tree_object.scale.lerp(max_scale,grow_speed * delta)
	
func spawn_bush():
	variant_bush_indexs = []
	for child in bush_object.get_children():
		child.queue_free()
	for i in 6:
		var random_x: float = randf_range(-0.3, 0.3)
		var random_z: float = randf_range(-0.3, 0.3)
		#var variant = variant_bushs.pick_random().instantiate()
		var index_bush = randi_range(0, variant_bushs.size()-1)
		var variant = variant_bushs[index_bush].instantiate()
		variant_bush_indexs.append(index_bush)
		bush_object.add_child(variant)
		variant.global_position = global_position + Vector3(random_x,0,random_z)
	pass
	
func finish_grow():
	if builder_controller and can_grow:
		#builder_controller.map.add_point(structure.reward_point)
		#builder_controller.update_point()
		builder_controller.show_reward(self.global_position,structure.reward_point)
		can_grow = false
		
		var original_scale = tree_object.scale
		# reward effect
		var tween = create_tween()
		tree_object.scale = Vector3.ONE * 0.5
		tween.tween_property(tree_object, "scale", original_scale, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		
		make_reward_interval()
		
func  make_reward_interval():
	var reward_timer = Timer.new()
	reward_timer.wait_time = grow_speed * 2
	reward_timer.autostart = true
	reward_timer.timeout.connect(_on_reward_timer_timeout)
	add_child(reward_timer)

func _on_reward_timer_timeout():
	give_reward()
	
func give_reward():
	#builder_controller.map.add_point(structure.reward_point)
	#builder_controller.update_point()
	var tween = create_tween()
	var original_scale = tree_object.scale
	tree_object.scale = Vector3.ONE * 0.5
	tween.tween_property(tree_object, "scale", original_scale, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	builder_controller.show_reward(self.global_position,structure.reward_point/2)
	
