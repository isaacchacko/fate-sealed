extends CharacterBody2D

signal enemy_clicked(node)
const SPEED = 60
const chase_speed = 100
var direction = -1
var fall = 0.5
var base_position: Vector2
var state := "idle" # possibilities are: "idle", "chase", "sit"
var player: Node2D = null
var sit_timer := 0.0


@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var goonba: AnimatedSprite2D = $AnimatedSprite2D
@onready var los_area: Area2D = $LOSpos
@onready var ray: RayCast2D = $los_ray
@onready var sign: AnimatedSprite2D = $AnimatedSprite2D2


@export var properties := ["global_position", "state"]
@export var los_y_offset: float = -12.0

var mat: ShaderMaterial
const SealShader = preload("res://shaders/seal.gdshader")

func _ready():
	HistoryManager.register_node(self, properties, false, true)
	mat = ShaderMaterial.new()
	mat.shader = SealShader
	$AnimatedSprite2D.material = mat
	mat.set_shader_parameter("enabled", false)

	los_area.body_entered.connect(_on_body_entered)
	los_area.body_exited.connect(_on_body_exited)
	$AnimatedSprite2D2.visible = false

func _physics_process(delta):
	if player and los_area.get_overlapping_bodies().has(player) and is_player_in_los():
		state = "chase"
	#else:
		#if state == "chase":
			#sit_timer = 1
			#state = "sit"
			#goonba.play("sit")
		#else:
			#state = "idle"
	match state:
		"idle":
			sign.hide()

			goonba.play("default")
			idle_move(delta)
		"chase":
			goonba.play("default")
			sign.show()
			chase_player(delta)
		"sit":
			goonba.play("sit")
			sign.hide()
			sit_timer -= delta
			if sit_timer <= 0.4:
				state = "idle"
				goonba.play("default") # Switch to idle animation after sitting

	var info = HistoryManager.get_registration(get_instance_id())
	print("info: ", info)
	if info['seal']['isSealed']:
		var highlighted = info['seal']['isSealed'] and HistoryManager.historyTime < info['seal']['expiresAt']
		mat.set_shader_parameter("enabled", highlighted)
	else:
		mat.set_shader_parameter("enabled", false)

func idle_move(delta: float):
	if ray_cast_left.is_colliding():
		direction = 1
	if ray_cast_right.is_colliding():
		direction = -1
	if not ray_cast_down.is_colliding():
		fall = 0.5
		position.y += SPEED * delta * 6
	else:
		fall = 1

	if direction == 1:
		goonba.flip_h = true
	else:
		goonba.flip_h = false
	if ray_cast_left.is_colliding() and ray_cast_right.is_colliding():
		sit_timer = 1.0
		state = "sit"
	else:
		position.x += direction * SPEED * delta * fall


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !HistoryManager.get_registration(get_instance_id())['seal']['isSealed']:
			HistoryManager.seal(self)

func _on_area_2d_mouse_entered() -> void:
	if FreezeControl.is_frozen and !HistoryManager.get_registration(get_instance_id())['seal']['isSealed']:
		mat.set_shader_parameter("enabled", true)


func _on_area_2d_mouse_exited() -> void:
	mat.set_shader_parameter("enabled", false)
	print("goonba: revert to grey if possible")

func chase_player(delta: float):
	if player.global_position.x > global_position.x:
		goonba.flip_h = true   # Player is to the right; face right (adjust as needed)
	else:
		goonba.flip_h = false    # Player is to the left; face left
	if player and is_player_in_los():
		if not ray_cast_down.is_colliding():
			fall = 0.5
			position.y += SPEED * delta * 1.5
		var x_direction = sign(player.global_position.x - global_position.x)
		velocity.x = x_direction * chase_speed
		velocity.y = 0  # Zero out vertical movement
		if ray_cast_left.is_colliding() and ray_cast_right.is_colliding():
			sit_timer = 1.0
			state = "sit"
		else:
			move_and_slide()
	else:
		state = "sit"

func _on_body_entered(body):
	player = body


func _on_body_exited(body):
	if body == player:
		#direction = 1
		sit_timer = 1.0
		if state == "chase":
			state = "sit"
			goonba.play("sit")

func is_player_in_los() -> bool:
	if not player:
		return false
	ray.global_position = global_position
	ray.target_position = (player.global_position + Vector2(0, los_y_offset)) - global_position
	ray.force_raycast_update()
	return ray.is_colliding() and ray.get_collider() == player

func _on_clickable_mouse_entered() -> void:
	if !HistoryManager.get_registration(get_instance_id())['seal']['isSealed']:
		mat.set_shader_parameter("enabled", true)
		print("goonba: change to yellow")


func _on_clickable_mouse_exited() -> void:
	mat.set_shader_parameter("enabled", false)
	print("goonba: revert to grey if possible")


func _on_clickable_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !HistoryManager.get_registration(get_instance_id())['seal']['isSealed']:
			print("goonba: Left mouse button was clicked inside the area! and historyTime=", HistoryManager.historyTime)
			HistoryManager.seal(self)
