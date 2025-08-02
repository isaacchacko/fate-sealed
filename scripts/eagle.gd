extends CharacterBody2D

@onready var goonba: AnimatedSprite2D = $AnimatedSprite2D
@onready var los_area: Area2D = $LOSEagle
@onready var ray: RayCast2D = $los_ray
@onready var ray_cast_bot: RayCast2D = $RayCastBot
@onready var ray_cast_top: RayCast2D = $RayCastTop


@export var properties := ["global_position"]
@export var idle_amplitude: float = 16.0
@export var idle_speed: float = 2.0
@export var idle2_speed: float = 40.0
@export var chase_speed: float = 120.0
@export var return_speed: float = 80.0
@export var los_y_offset: float = -16.0

var base_position: Vector2
var state := "idle" # possibilities are: "idle", "chase", "return"
var player: Node2D = null
var direction = 1 # 1 for continue path
var idle_center: Vector2
var center = 0


func _ready():
	# HistoryManager.register_node(self, properties)
	base_position = global_position
	los_area.body_entered.connect(_on_body_entered)
	los_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if player and los_area.get_overlapping_bodies().has(player) and is_player_in_los():
		state = "chase"
	match state:
		"idle":
			idle_hover(delta)
		"chase":
			chase_player(delta)
		"return":
			return_home(delta)
		"idle2":
			idle_hover_p2(delta)

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
		
		


	
