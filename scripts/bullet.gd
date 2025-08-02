extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float

var speed = 250.0
var jump_velocity = -300.0
var gravity = 1000.0  # Adjust this to control arc steepness


func _ready() -> void:
	global_position = pos
	global_rotation = rota

	# Set initial velocity using direction
	velocity = Vector2(speed, 0).rotated(dir)

	velocity.x = speed * cos(dir)
	velocity.y = jump_velocity

func _physics_process(delta: float) -> void:
	# Apply gravity to vertical velocity
	velocity.y += gravity * delta

	# Move and check for collision
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider() is TileMap:
			queue_free()
