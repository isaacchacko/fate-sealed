extends CharacterBody2D

@onready var goonba: AnimatedSprite2D = $AnimatedSprite2D
@onready var los_area: Area2D = $LOSEagle
@onready var ray: RayCast2D = $los_ray
@onready var ray_cast_bot: RayCast2D = $RayCastBot
@onready var ray_cast_top: RayCast2D = $RayCastTop
@onready var exclaimsign: AnimatedSprite2D = $AnimatedSprite2D2
@onready var questionsign: AnimatedSprite2D = $AnimatedSprite2D3
@onready var hitbox = get_node("goonbadeath/Area2D")


@export var properties := ["global_position", "state"]
@export var idle_amplitude: float = 36.0
@export var idle_speed: float = 2.0
@export var idle2_speed: float = 40.0
@export var chase_speed: float = 120.0
@export var return_speed: float = 80.0
@export var los_y_offset: float = -16.0

var base_position: Vector2
var idle_center
var state
#var idle_center = global_position
#var state := "idle2" # possibilities are: "idle", "chase", "return"
var player: Node2D = null
var direction = 1 # 1 for continue path
var center = 0

var mat: ShaderMaterial
const SealShader = preload("res://shaders/seal.gdshader")

func _ready():
	var idle_center = global_position
	var state := "idle2"
	questionsign.hide()
	HistoryManager.register_node(self, properties, false, true)

	mat = ShaderMaterial.new()
	mat.shader = SealShader
	$AnimatedSprite2D.material = mat
	mat.set_shader_parameter("enabled", false)

	base_position = global_position
	los_area.body_entered.connect(_on_body_entered)
	los_area.body_exited.connect(_on_body_exited)
var froze = false
var first = true

func _physics_process(delta):
	if !FreezeControl.is_frozen:
		var info = HistoryManager.get_registration(get_instance_id())
		var isSealed = info['seal']['isSealed']
		var sealExpiresAt = info['seal']['expiresAt']
		var historyTime = HistoryManager.historyTime
		var seal_visual_bool = isSealed and sealExpiresAt and historyTime < sealExpiresAt
		mat.set_shader_parameter("enabled", seal_visual_bool)
		hitbox.monitoring = not seal_visual_bool

	if FreezeControl.is_frozen:
		froze = true
		return
	if froze:
		idle_center = global_position
		state = "idle2"
		froze = false
	if player and los_area.get_overlapping_bodies().has(player) and is_player_in_los():
		state = "chase"
	match state:
		"idle":
			exclaimsign.hide()
			questionsign.hide()
			idle_hover(delta)
			#idle_hover_p2(delta)
		"chase":
			exclaimsign.show()
			questionsign.hide()
			chase_player(delta)
			first = true
		"return":
			exclaimsign.hide()
			questionsign.hide()
			return_home(delta)
		"idle2":
			exclaimsign.hide()
			if first == true:
				questionsign.show()
				await get_tree().create_timer(1.5).timeout
				questionsign.hide()
			idle_hover_p2(delta)
			first = false

func _on_body_entered(body):
	player = body


func _on_body_exited(body):
	if body == player:
		idle_center = global_position
		direction = 1
		state = "idle2"

func idle_hover(delta):
	if (ray_cast_bot.is_colliding() or ray_cast_top.is_colliding()):
		direction = direction * -1
	if not FreezeControl.is_frozen:
		global_position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * idle_speed) * idle_amplitude * direction



func idle_hover_p2(delta):
	if ray_cast_bot.is_colliding() or ray_cast_top.is_colliding():
		direction *= -1
	elif abs(global_position.y - idle_center.y) > idle_amplitude:
		direction *= -1

	global_position.y += idle2_speed * delta * direction


func chase_player (delta):
	if player.global_position.x > global_position.x:
		goonba.flip_h = true   # Player is to the right; face right (adjust as needed)
	else:
		goonba.flip_h = false    # Player is to the left; face left
	if player and is_player_in_los():
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * chase_speed
		move_and_slide()
	else:
		idle_center = global_position
		direction = 1
		state = "idle2"

# currently not used, would be useful if we ever want it to return to base
func return_home(delta):
	var to_base = base_position - global_position
	if to_base.length() < 2:
		global_position = base_position
		velocity = Vector2.ZERO
		idle_center = global_position
		direction = 1
		state = "idle2"
		return
	var direction = to_base.normalized()
	velocity = direction * return_speed
	move_and_slide()
	#check for player re-entering LOS
	if player and los_area.get_overlapping_bodies().has(player) and is_player_in_los():
		state = "chase"

func is_player_in_los() -> bool:
	if not player:
		return false
	ray.global_position = global_position
	ray.target_position = (player.global_position + Vector2(0, los_y_offset)) - global_position
	ray.force_raycast_update()
	return ray.is_colliding() and ray.get_collider() == player

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
