extends Node

@export var chunk_size := 32
@export var view_distance := 2
@export var SkyTile := 0
@export var GrassTile := 1
@export var DirtTile := 2
@export var LavaTile := 3

@onready var Player = null

var chunks := {} # Dictionary to store generated chunks

func get_tile_for_height(y: int) -> int:
	if y < -50:
		return SkyTile
	elif y < 0:
		return GrassTile
	elif y < 50:
		return DirtTile
	else:
		return LavaTile
		
func generate_chunk(chunk_coord: Vector2i):
	var chunk = TileMap.new()
	chunk.tile_set = $TileMapLayer.tile_set # Replace with your TileMap node containing the TileSet
	chunk.position = chunk_coord * chunk_size * 32
	add_child(chunk)
	chunks[chunk_coord] = chunk

	for x in range(chunk_size):
		for y in range(chunk_size):
			#var world_x = chunk_coord.x * chunk_size + x
			var world_y = chunk_coord.y * chunk_size + y
			var tile_id = get_tile_for_height(world_y)
			chunk.set_cell(0, Vector2i(x, y), tile_id)

			
func GetPlayerChunk() -> Vector2:
	var player_pos = Player.global_position
	return Vector2(floor(player_pos.x / (chunk_size * 32)), floor(player_pos.y / (chunk_size * 32)))

func generate_nearby_chunks(center_chunk: Vector2):
	for x in range(-view_distance, view_distance + 1):
		for y in range(-view_distance, view_distance + 1):
			var chunk_coord = Vector2i(center_chunk.x + x, center_chunk.y + y)
			if not chunks.has(chunk_coord):
				generate_chunk(chunk_coord)

func unload_far_chunks(center_chunk: Vector2i):
	for key in chunks.keys():
		if (key - center_chunk).length() > view_distance:
			chunks[key].queue_free()
			chunks.erase(key)

func _process(_delta):
	if Player == null:
		Player = get_tree().get_root().find_child("Player", true, false)
		return
	var PlayerChunk = GetPlayerChunk()
	generate_nearby_chunks(PlayerChunk)
	unload_far_chunks(PlayerChunk)
