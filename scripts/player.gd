extends CharacterBody2D
var bullet_path=preload("res://scenes/bullet.tscn")


const SPEED = 200.0
const JUMP_VELOCITY = -300.0

@onready var muzzle = $BombSpawn
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

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
	
	#Handles bombspawn rotations
	if direction > 0:
		animated_sprite_2d.flip_h = false
		muzzle.position.x = abs(muzzle.position.x)
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		muzzle.position.x = -abs(muzzle.position.x)
	
	
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
