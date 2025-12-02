extends Node2D

@export var max_health: int = 100
var health: float = max_health
var damage: float = 50

func _ready():
	health = max_health

func take_damage(amount: float):
	health -= amount
	if health < 0.1:
		queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		print("Is player")
	else:
		print("Is not player")
		var AreaParent = area.get_parent()
	# Only damage if that node has the function
		if AreaParent.has_method("take_damage"):
			print("do daamge")
			AreaParent.take_damage(damage)
		else:
			print("has no take damage")
