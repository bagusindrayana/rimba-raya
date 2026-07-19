extends Button


var hover_scale: Vector2 = Vector2(1.1, 1.1)
var original_scale: Vector2 = Vector2(1.0, 1.0)
var hover_duration: float = 0.15 # animation time in second

@export_subgroup("Toggle UI")
@export var texture_rect_button : TextureRect
@export var texture_button_on : Texture2D
@export var texture_button_off : Texture2D
@export var game_ui : Node
@export var selector_ui : Node
@export var camera_controller : CameraController 


var on : bool = false

var tween: Tween

func _ready() -> void:
	pivot_offset = size / 2.0
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	on = false
	if texture_rect_button:
		toggled.connect(_on_button_toggled)
		print("toggle")

func _process(delta: float) -> void:
	pass
	#if texture_button:
		#if on:
			#texture_button.texture = texture_button_on
		#else:
			#texture_button.texture = texture_button_off

func _on_mouse_entered() -> void:
	animate_button(hover_scale)

func _on_mouse_exited() -> void:
	animate_button(original_scale)

func animate_button(target_scale: Vector2) -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", target_scale, hover_duration)


func _on_button_toggled(toggled_on: bool) -> void:
	on = toggled_on
	if texture_rect_button:
		if toggled_on:
			texture_rect_button.texture = texture_button_on
			if game_ui:
				game_ui.hide()
			if selector_ui:
				selector_ui.hide()
		else:
			texture_rect_button.texture = texture_button_off
			if game_ui:
				game_ui.show()
			if selector_ui:
				selector_ui.show()
		if camera_controller:
			camera_controller.can_orbit = toggled_on

func exit_game():
	get_tree().quit()

func load_game():
	get_tree().change_scene_to_file("res://scenes/World.tscn")
