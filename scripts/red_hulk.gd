extends CharacterBody2D

@onready var hulk: AnimatedSprite2D = $AnimatedSprite2D
@onready var large_los_area: Area2D = $LargeLOSHulk
@onready var ray: RayCast2D = $los_hulk_ray
@onready var small_los_area: Area2D = $SmallLOSHulk

@export var properties := ["global_position"]
@export var los_y_offset: float = -16.0
@onready var muzzle = $BombSpawn
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox = get_node('goonbadeath/Area2D')

var can_throw := true
var state := "idle"
var player: Node2D = null
var mat: ShaderMaterial
const SealShader = preload("res://shaders/seal.gdshader")

var dirt_block_scene = preload("res://scenes/dirt_block.tscn") # Just preload, don't instantiate yet

func _ready():
	HistoryManager.register_node(self, properties, false, true)
	large_los_area.body_entered.connect(_on_body_entered)
	large_los_area.body_exited.connect(_on_body_large_exited)
	small_los_area.body_entered.connect(_on_body_small_entered)
	small_los_area.body_exited.connect(_on_body_small_exited)
	#shoot_cooldown_timer.timeout.connect(_on_shoot_cooldown_timeout)
	
	mat = ShaderMaterial.new()
	mat.shader = SealShader
	$AnimatedSprite2D.material = mat
	mat.set_shader_parameter("enabled", false)

func _physics_process(delta):

	if !FreezeControl.is_frozen:
		var info = HistoryManager.get_registration(get_instance_id())
		if info != {}:
			var isSealed = info['seal']['isSealed']
			var sealExpiresAt = info['seal']['expiresAt']
			var historyTime = HistoryManager.historyTime
			var seal_visual_bool = isSealed and sealExpiresAt and historyTime < sealExpiresAt
			mat.set_shader_parameter("enabled", seal_visual_bool)
			hitbox.monitoring = not seal_visual_bool

	if player and small_los_area.get_overlapping_bodies().has(player) and is_player_in_los() and not FreezeControl.is_frozen:
		if can_throw:
			state = "throw"
		await get_tree().create_timer(3).timeout
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
			await get_tree().create_timer(3).timeout
		"throw":
			hulk.play("GroundPound")
			throw_shit()
			await get_tree().create_timer(3).timeout
			state = "postSpotIdle" # Only throw once until state changes
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

func throw_shit():
	if not can_throw:
		return
	can_throw = false

	# Flip hulk sprite to face player
	if player.global_position.x > global_position.x:
		hulk.flip_h = false
	else:
		hulk.flip_h = true

	# Instance dirt block
	var dirt_block = dirt_block_scene.instantiate()
	# Start position: spawn from BombSpawn
	dirt_block.pos = $BombSpawn.global_position


	dirt_block.rota = rotation
	# Compute direction in radians from dirt block spawn to player
	var direction_angle = (player.global_position - dirt_block.pos).angle()
	var x_distance = player.global_position.x - dirt_block.pos.x
	dirt_block.target_position = player.global_position
	dirt_block.start = dirt_block.pos
	# Make sure to play throw animation (requires the property/variable in your dirt_block script)
	if dirt_block.has_node("AnimatedSprite2D"):
		dirt_block.get_node("AnimatedSprite2D").play("throw")
	# Add to scene
	get_parent().add_child(dirt_block)

	await get_tree().create_timer(3.0).timeout
	can_throw = true

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
