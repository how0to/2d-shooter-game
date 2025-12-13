extends CharacterBody2D

@onready var PlayerHitbox: Area2D = $Area2D

const SPEED = 120.0
const BulletSpeed = 1000
const JUMP_VELOCITY = -400.0
var max_health: int = 1000
var health: float = max_health
var MouseDir = 0
var shoot_cooldown := 1.25  # seconds between shots
var last_shot_time := 0.0  # last time we fired

signal player_spawned(player)

func _physics_process(_delta: float) -> void:
	MouseDir = (get_global_mouse_position() - global_position).normalized()
	if Input.is_action_just_pressed("Fire"):
		try_shoot()
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

func get_cooldown_percent() -> float:
	var now = Time.get_ticks_msec() / 1000.0
	var progress = (now - last_shot_time) / shoot_cooldown
	return clamp(progress, 0.0, 1.0)

func try_shoot():
	var now = Time.get_ticks_msec() / 1000.0  # convert ms → seconds

	if now - last_shot_time >= shoot_cooldown:
		shoot()
		last_shot_time = now

func shoot():
	var bullet = preload("res://Scenes/bullet.tscn").instantiate()
	bullet.global_position = PlayerHitbox.global_position
	bullet.direction = MouseDir
	bullet.rotation = bullet.direction.angle()
	get_tree().get_current_scene().add_child(bullet)

func take_damage(amount: float):
	health -= amount
	if health < 0.1:
		queue_free()
