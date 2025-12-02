extends Node

var PlayerTemplate = preload("res://Scenes/player.tscn")

func _ready() -> void:
	print("Ready")
	var Player = PlayerTemplate.instantiate()
	print("Player exists")
	get_tree().get_current_scene().add_child(Player)
	print("Player parent set")
	Player.add_to_group("Player")
	Player.global_position = Vector2(0,0)
	print("WHY PLS WORK")
