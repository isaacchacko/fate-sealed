extends CharacterBody2D

@export var properties := ["global_position", "velocity", "alive"]

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var pos: Vector2
var rota: float
var dir: float
var target_position: Vector2
var start: Vector2

var speedx = 250.0
var sppedy = 250.0
var jump_velocity = -300.0
var gravity = 1000.0

var alive := true

func _ready() -> void:
	HistoryManager.register_node(self, properties, true, false)
	global_position = pos
	global_rotation = rota
	launch_to_target(target_position)
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
		await get_tree().create_timer(.5).timeout
		hide()

func launch_to_target(target_position: Vector2, gravity: float = 980, arc_height: float = 100):
	var start = global_position
	var displacement = target_position - start
	arc_height = clamp(displacement.length() * 0.25, 50, 300)
	var peak_y = min(start.y, target_position.y) - arc_height
	var time_to_peak = sqrt(2 * (start.y - peak_y) / gravity)
	var total_time = time_to_peak + sqrt(2 * (target_position.y - peak_y) / gravity)
	var vx = displacement.x / total_time
	var vy = -gravity * time_to_peak
	velocity = Vector2(vx, vy)


func set_alive(is_alive: bool) -> void:
	if alive != is_alive:
		alive = is_alive
		if alive:
			show()
		# don't hide immediately, let explosion play
		else:
			await get_tree().create_timer(.25).timeout
			hide()

func _on_explosion_finished():
	if anim_sprite.animation == "explosion":
		await get_tree().create_timer(.25).timeout
		queue_free()
