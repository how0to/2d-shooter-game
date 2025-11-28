extends CharacterBody2D

@onready var PlayerHitbox: CollisionShape2D = $CollisionShape2D

const SPEED = 300.0
const BulletSpeed = 1000
const JUMP_VELOCITY = -400.0
var MouseDir = 0

func _physics_process(_delta: float) -> void:
	MouseDir = (get_global_mouse_position() - global_position).normalized()
	if Input.is_action_just_pressed("Fire"):
		shoot()
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.dd
	var direction := Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2(0, 0)
		
	move_and_slide()

func shoot():
	var bullet = preload("res://Scenes/bullet.tscn").instantiate()
	bullet.global_position = PlayerHitbox.global_position
	bullet.direction = MouseDir
	bullet.rotation = bullet.direction.angle()
	get_tree().get_current_scene().add_child(bullet)
