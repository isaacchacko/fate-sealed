extends CharacterBody2D
var bullet_path=preload("res://scenes/bullet.tscn")
signal player_died

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

@onready var muzzle = $BombSpawn
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var properties := ["global_position"]

var death_jump_velocity = -300  # Upward impulse (negative y is up)
var gravity = 800
var is_dead = false
var death_velocity = Vector2.ZERO

func _ready():
	HistoryManager.register_node(self, properties, false, false)

func check_spike_collision():
	if is_dead == false:
		var tilemap = get_node("../SpikeTileMap") # Adjust path as needed
		var tile_coords = tilemap.local_to_map(global_position)
		var tile_data = tilemap.get_cell_tile_data(0, tile_coords)  # 0 is the layer index

		if tile_data and tile_data.get_custom_data("deadly"):
			player_died.emit()

		
		

func _physics_process(delta: float) -> void:
	if FreezeControl.is_frozen:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("fire"):
		fire()

	if is_dead:
		velocity.y += gravity * delta  # Gravity pulls down

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#movement is 1,0,-1
	
	var direction := Input.get_axis("move_left", "move_right")
	if is_dead == true:
		direction =0

	check_spike_collision()
		
	#to flip sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	#Handles bombspawn rotations
	if direction > 0:
		animated_sprite_2d.flip_h = false
		muzzle.position.x = abs(muzzle.position.x)
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		muzzle.position.x = -abs(muzzle.position.x)


	#choose which animations are played
	if is_on_floor() and is_dead == false:
		if direction == 0:
			animated_sprite_2d.play("IDLE")
		elif !(direction == 0):
			animated_sprite_2d.play("Running")
	else:
		if velocity.y < 0 and is_dead == false:
			animated_sprite_2d.play("jumping_up")
		elif velocity.y > 0 and is_dead == false:
			animated_sprite_2d.play("jumping_down")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func die():
	is_dead = true
	var deathY = global_position.y +162.5
	$Camera2D.limit_bottom = deathY
	animated_sprite_2d.play("Death")
	velocity.y = death_jump_velocity
	collision_layer = 0
	collision_mask = 0
	var timer = Timer.new()
	print("you sssss balls")
	await get_tree().create_timer(1).timeout	
	HistoryManager.reset_all()
	get_tree().reload_current_scene()
	

func fire():
	var bullet=bullet_path.instantiate()
	bullet.pos=$BombSpawn.global_position
	bullet.rota=global_rotation
	if animated_sprite_2d.flip_h:
		bullet.dir = PI  # 180 degrees in radians
	else:
		bullet.dir = 0  # Facing right
	get_parent().add_child(bullet)
