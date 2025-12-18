extends Node

var PlayerTemplate = preload("res://Scenes/player.tscn")

func _ready() -> void:
	#var SpawnLocation: Node2D = get_node("/Game/SpawnLocation")
	var Player = PlayerTemplate.instantiate()
	get_tree().get_current_scene().add_child.call_deferred(Player)
	Player.add_to_group("Player")
	Player.global_position = Vector2(0,0)
	#Player.global_position = SpawnLocation
	Player.player_spawned.emit(Player)
	Data.register_player(Player, true)
