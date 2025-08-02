extends Node2D
const SPEED = 60.0
var direction = -1
var fall = 0.5

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var killzone = $killzone



func _process(delta: float):
	if ray_cast_left.is_colliding():
		direction = 1
	if ray_cast_right.is_colliding():
		direction = -1
	if not ray_cast_down.is_colliding():
		fall = 0.5
		position.y += SPEED * delta
	else:
		fall = 1
	position.x += direction * SPEED * delta * fall
