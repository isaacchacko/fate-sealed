extends CharacterBody2D
var bullet_path=preload("res://scenes/bullet.tscn")
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
@onready var player = get_node("res://scenes/player.tscn")

@onready var muzzle = $BombSpawn
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var properties := ["global_position"]

signal player_died


func _ready():
	HistoryManager.register_node(self, properties, false)

func check_deadly_collision():
	var tilemap = get_node("../SpikeTileMap") # Adjust path as needed
	var tile_coords = tilemap.local_to_map(player.global_position)
	var tile_data = tilemap.get_cell_tile_data(0, tile_coords)  # 0 is the layer index

	if tile_data and tile_data.get_custom_data("deadly"):
		print("you sssss balls")
		player_died.emit()
		HistoryManager.reset_all()
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("fire"):
		fire()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#movement is 1,0,-1
	var direction := Input.get_axis("move_left", "move_right")

	#to flip sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	check_deadly_collision()

	#Handles bombspawn rotations
	if direction > 0:
		animated_sprite_2d.flip_h = false
		muzzle.position.x = abs(muzzle.position.x)
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		muzzle.position.x = -abs(muzzle.position.x)		
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is TileMap:
			var tilemap = collision.get_collider() as TileMap
			var coords = tilemap.local_to_map(self.global_position)
			var tile_data = tilemap.get_cell_tile_data(0, coords)

			if tile_data != null and tile_data.get_custom_data("deadly") == true:
				print("you sssss balls")
				player_died.emit()
				HistoryManager.reset_all()
				get_tree().reload_current_scene()

	


	#choose which animations are played
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("IDLE")
		elif !(direction == 0):
			animated_sprite_2d.play("Running")
	else:
		if velocity.y < 0:
			animated_sprite_2d.play("jumping_up")
		elif velocity.y > 0:
			animated_sprite_2d.play("jumping_down")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func fire():
	var bullet=bullet_path.instantiate()
	bullet.pos=$BombSpawn.global_position
	bullet.rota=global_rotation
	if animated_sprite_2d.flip_h:
		bullet.dir = PI  # 180 degrees in radians
	else:
		bullet.dir = 0  # Facing right
	get_parent().add_child(bullet)
