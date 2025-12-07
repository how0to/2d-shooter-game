extends CharacterBody2D

@export var max_health: int = 100
var health: float = max_health
var damage: float = 50
var player: CharacterBody2D
var speed = 150

func _ready():
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("Player")
	health = max_health

func take_damage(amount: float):
	health -= amount
	if health < 0.1:
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void: 
	if area.is_in_group("Player"):
		var AreaParent = area.get_parent()
	# Only damage if that node has the function
		if AreaParent.has_method("take_damage"):
			AreaParent.take_damage(damage)

func _physics_process(_delta):
	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
