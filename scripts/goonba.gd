extends CharacterBody2D

signal enemy_clicked(node)
const SPEED = 60
var direction = -1
var fall = 0.5

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var goonba: AnimatedSprite2D = $AnimatedSprite2D
@export var properties := ["global_position"]

var mat: ShaderMaterial

func _ready():
	HistoryManager.register_node(self, properties, false, true)
	mat = ShaderMaterial.new()
	mat.shader = preload("res://shaders/seal.gdshader")
	$AnimatedSprite2D.material = mat
	mat.set_shader_parameter("enabled", false)


func _process(delta: float):
	if ray_cast_left.is_colliding():
		direction = 1
		goonba.flip_h = true
	if ray_cast_right.is_colliding():
		direction = -1
		goonba.flip_h = false
	if not ray_cast_down.is_colliding():
		fall = 0.5
		position.y += SPEED * delta
	else:
		fall = 1
	position.x += direction * SPEED * delta * fall


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !HistoryManager.get_registration(get_instance_id())['seal']['isSealed']:
			print("goonba: Left mouse button was clicked inside the area!")
			HistoryManager.seal(self)

func _on_area_2d_mouse_entered() -> void:
	if !HistoryManager.get_registration(get_instance_id())['seal']['isSealed']:
		mat.set_shader_parameter("enabled", true)
		print("goonba: change to yellow")

	#shader_type canvas_item;
#
#uniform float tint_strength : hint_range(0.0, 1.0) = 1.0;
#
#void fragment() {
	#vec4 tex_color = texture(TEXTURE, UV);
	#// Pure yellow tint (RGB: 1.0, 1.0, 0.0)
	#vec3 yellow = vec3(1.0, 1.0, 0.0);
	#vec3 tinted = mix(tex_color.rgb, yellow, tint_strength);
	#COLOR = vec4(tinted, tex_color.a);
#}
func _on_area_2d_mouse_exited() -> void:
	mat.set_shader_parameter("enabled", false)
	print("goonba: revert to grey if possible")
