extends CharacterBody2D

@export var max_health := 100
var health: float = max_health
var damage := 50
var speed := 150
var xp := 10

var player: CharacterBody2D = null

func _ready():
	health = max_health

func _on_player_registered(p):
	player = p

func take_damage(amount: float):
	health -= amount
	if health < 0.1:
		Data.add_score(xp)
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Player"):
		return

	var parent := area.get_parent()
	if parent.has_method("take_damage"):
		parent.take_damage(damage)


func _physics_process(_delta):
	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
	else:
		player = get_closest_player()

func get_closest_player() -> CharacterBody2D:
	var closest: CharacterBody2D = null
	var best_dist := INF

	for p in Data.players:
		if not is_instance_valid(p):
			continue

		var d := global_position.distance_squared_to(p.global_position)
		if d < best_dist:
			best_dist = d
			closest = p

	return closest
