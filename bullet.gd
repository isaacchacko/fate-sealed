extends CharacterBody2D
var pos:Vector2
var rota:float
var dir : float
var speed = 2000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position=pos
	global_rotation=rota

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity=Vector2(speed,0).rotated(dir)
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		if collision.get_collider() is TileMap:
			queue_free()  # Deletes the bullet on impact
