extends Node2D

@onready var hitbox: Area2D = $Hitbox
var BulletAbility = preload("uid://ob8a14jt6xfa")
@export var speed: float = BulletAbility.ProjectileSpeed
var damage = 50
var pierce = 1
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		var AreaParent = area.get_parent()
	# Only damage if that node has the function
		if AreaParent.has_method("take_damage"):
			AreaParent.take_damage(damage)
	if pierce == 0:
		queue_free()   # Destroy the bullet after hit
	else:
		pierce -= 1
