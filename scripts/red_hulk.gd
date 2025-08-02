extends CharacterBody2D

@onready var hulk: AnimatedSprite2D = $AnimatedSprite2D
@onready var large_los_area: Area2D = $LargeLOSHulk
@onready var ray: RayCast2D = $los_hulk_ray
@onready var small_los_area: Area2D = $SmallLOSHulk


@export var properties := ["global_position"]
@export var los_y_offset: float = -16.0

var state := "idle" # possibilities are: "idle", "chase", "return"
var player: Node2D = null


func _ready():
	HistoryManager.register_node(self, properties, false)
	large_los_area.body_entered.connect(_on_body_entered)
	large_los_area.body_exited.connect(_on_body_large_exited)
	small_los_area.body_entered.connect(_on_body_small_entered)
	small_los_area.body_exited.connect(_on_body_small_exited)

func _physics_process(delta):
	if player and small_los_area.get_overlapping_bodies().has(player) and is_player_in_los():
		state = "throw"
	elif player and large_los_area.get_overlapping_bodies().has(player):
		state = "postSpotIdle"
	match state:
		"idle":
			hulk.play("idle")
		"wakey":
			hulk.play("wakey")
			await hulk.animation_finished
			state = "postSpotIdle"
		"postSpotIdle":
			hulk.play("postSpotIdle")
		"throw":
			throw_shit(delta)
		"nighty":
			hulk.play("nighty")
			await hulk.animation_finished
			state = "idle"

func _on_body_entered(body):
	player = body
	state = "wakey"

func _on_body_small_entered(body):
	player = body
	state = "throw"

func _on_body_small_exited(body):
	if body == player:
		state = "postSpotIdle"
		
func _on_body_large_exited(body):
	if body == player:
		state = "nighty"

func throw_shit(delta):
	pass
# currently not used, would be useful if we ever want it to return to base
func is_player_in_los() -> bool:
	if not player:
		return false
	ray.global_position = global_position
	ray.target_position = (player.global_position + Vector2(0, los_y_offset)) - global_position
	ray.force_raycast_update()
	return ray.is_colliding() and ray.get_collider() == player
		
		


	
