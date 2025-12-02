extends Node

@export var SpawnDistance: float = 500.0      # How far from player to spawn
@export var SpawnRate: float = 1.5           # Seconds between spawns
#@export var player_path: NodePath

@onready var player: CharacterBody2D = $"../Player"
var EnemyScene = preload("res://Scenes/enemy_1.tscn")

func _ready():
	#player = get_node(player_path)
	spawn_enemy()
	spawn_timer()

func get_camera_bounds() -> Rect2:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return Rect2()

	# viewport size in pixels
	var vp_size: Vector2 = get_viewport().get_visible_rect().size

	# world size that the camera currently covers (accounts for zoom)
	# Note: cam.zoom is a Vector2
	var world_size: Vector2 = vp_size * cam.zoom

	# camera global_position is the center of the view in world coords
	var top_left: Vector2 = cam.global_position - world_size * 0.5

	return Rect2(top_left, world_size)

func get_spawn_position() -> Vector2:
	var rect = get_camera_bounds()
	var margin = 200.0

	var side = randi() % 4
	match side:
		0: # Top
			return Vector2(randf_range(rect.position.x, rect.position.x + rect.size.x),
						   rect.position.y - margin)
		1: # Bottom
			return Vector2(randf_range(rect.position.x, rect.position.x + rect.size.x),
						   rect.position.y + rect.size.y + margin)
		2: # Left
			return Vector2(rect.position.x - margin,
						   randf_range(rect.position.y, rect.position.y + rect.size.y))
		3: # Right
			return Vector2(rect.position.x + rect.size.x + margin,
						   randf_range(rect.position.y, rect.position.y + rect.size.y))

	return Vector2.ZERO

func spawn_timer():
	spawn_enemy()
	await get_tree().create_timer(SpawnRate).timeout
	spawn_timer()

func spawn_enemy():
	if player == null:
		return

	# Optional spawn rate scaling
	if SpawnRate > 0.001:
		SpawnRate *= 0.99
	else:
		SpawnRate = 0.001

	var spawn_pos = get_spawn_position()

	var enemy = EnemyScene.instantiate()
	enemy.get_node("Hitbox").add_to_group("enemy")
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)
