extends CharacterBody2D

@export var properties := ["global_position", "velocity", "alive"]

var pos: Vector2
var rota: float
var dir: float

var speed = 250.0
var jump_velocity = -300.0
var gravity = 1000.0  # Adjust this to control arc steepness

var alive := true

func _ready() -> void:
	HistoryManager.register_node(self, properties, true, false)

	global_position = pos
	global_rotation = rota
	velocity.x = speed * cos(dir)
	velocity.y = jump_velocity

func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision and collision.get_collider() is TileMap:
		set_alive(false)

# HAS to be defined so that HistoryManager can immediately trigger a hide/show
# when alive changes. i miss useEffect
func set_alive(is_alive: bool) -> void:
	if alive != is_alive:
		alive = is_alive
		if alive:
			show()
		else:
			hide()
