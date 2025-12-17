extends Node

signal score_changed(new_score)
signal player_registered(player)
signal player_unregistered(player)

var level
var players: Array[CharacterBody2D] = []
var local_player: CharacterBody2D = null

var AbilityPool: Array[AbilityData] = [
	preload("uid://dm74nbhp2i2u6"),
	preload("uid://ob8a14jt6xfa"),
	preload("uid://6k81wj73e850"),
]

func add_score(amount: int):
	local_player.score += amount
	local_player.ScoreLabel.text = "Score: " + str(local_player.score)
	print(local_player.score)
	score_changed.emit(local_player.score)

func register_player(player: CharacterBody2D, is_local := true):
	if player in players:
		return

	players.append(player)

	if is_local:
		local_player = player

	player_registered.emit(player)

func unregister_player(player: CharacterBody2D):
	if player == local_player:
		local_player = null
		
	players.erase(player)
	player_unregistered.emit(player)

func _process(_delta: float) -> void:
	for player in players:
		if player.xp >= player.ReqXp:
			player.LevelUp()
			player.xp -= player.ReqXp
			player.ReqXp *= 1.05
