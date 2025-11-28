extends Node

@export var SpawnDistance: float = 0.0      # How far off-screen to spawn
@export var SpawnRate: float = 1.5            # Seconds between spawns
@export var player_path: NodePath

@onready var player: CharacterBody2D = $"../Player"
var EnemyScene = preload("res://Scenes/enemy_1.tscn")

func _ready():
	player = get_node(player_path)
	spawn_timer()

func spawn_timer():
	spawn_enemy()
	await get_tree().create_timer(SpawnRate).timeout
	spawn_timer()

func spawn_enemy():
	if player == null:
		return

	# Reduce spawn rate but clamp minimum
	if SpawnRate > 0.1:
		SpawnRate *= 0.75
	else:
		SpawnRate = 0.1

	# Random angle around player (2D)
	var angle = randf() * TAU
	var offset = Vector2(
		cos(angle) * SpawnDistance,
		sin(angle) * SpawnDistance
	)
	
	# Correct 2D position
	var spawn_pos = player.global_position + offset

	var enemy = EnemyScene.instantiate()
	enemy.global_position = spawn_pos

	get_tree().current_scene.add_child(enemy)
