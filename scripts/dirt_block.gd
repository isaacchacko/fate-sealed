extends CharacterBody2D

@export var properties := ["global_position", "velocity", "alive"]

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var pos: Vector2
var rota: float
var dir: float

var speed = 250.0
var jump_velocity = -300.0
var gravity = 1000.0

var alive := true

func _ready() -> void:
	HistoryManager.register_node(self, properties, true)
	global_position = pos
	global_rotation = rota
	velocity.x = speed * cos(dir)
	velocity.y = jump_velocity
	anim_sprite.play("throw") # Begin with throw animation

func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision and collision.get_collider() is TileMap:
		set_alive(false)
		anim_sprite.play("explosion")
		anim_sprite.connect("animation_finished", Callable(self, "_on_explosion_finished"), CONNECT_ONE_SHOT)

func set_alive(is_alive: bool) -> void:
	if alive != is_alive:
		alive = is_alive
		if alive:
			show()
		# don't hide immediately, let explosion play
		else: hide()

func _on_explosion_finished():
	if anim_sprite.animation == "explosion":
		queue_free()
