extends Node2D

@export var max_health: int = 10
var health: float = 500

func _ready():
	health = max_health

func take_damage(amount: float):
	health -= amount
	if health < 0.1:
		queue_free()
