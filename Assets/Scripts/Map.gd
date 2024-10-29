extends TileMap

signal area_eat(tile_eat: bool)

@export_node_path("Area2D") var player_path
@onready var player = get_node(player_path) as Area2D
@export_node_path("Area2D") var enemy_path
@onready var enemy = get_node(enemy_path) as Area2D

func get_initialize_position():
	var position_map = map_to_local(Vector2(14, 23))
	return position_map

func is_tile_vacant(position_pacman: Vector2i, direction: Vector2i):
	var next_tile_position: Vector2 = Vector2.LEFT
	var current_tile = local_to_map(position_pacman)
	var next_tile = get_cell_atlas_coords(0, current_tile + direction)
	if next_tile in eat_tiles(): #!get_cell_tile_data(0, next_tile).get_custom_data("wall"):
		next_tile_position = map_to_local(current_tile + direction)
		area_eat.emit(true)
	else:
		area_eat.emit(false)
		next_tile_position = relocate(position_pacman)
	print(get_cell_tile_data(0, next_tile).get_custom_data("wall") )
	return next_tile_position

func relocate(position_pacman: Vector2):
	var tile_position = local_to_map(position_pacman)
	return map_to_local(tile_position)

func eat(position_pacman: Vector2):
	var current_tile = local_to_map(position_pacman)
	var tile = get_cell_atlas_coords(0, current_tile)
	if tile in eat_tiles():
		set_cell(0, current_tile, 0, Vector2i(12, 2))

func _process(delta: float) -> void:
	var count = 0
	for i in range(get_used_rect().size.x):
		for l in range(get_used_rect().size.y):
			if get_cell_atlas_coords(0, Vector2i(i, l)) == Vector2i(13, 2):
				count += 1
	if count == 0:
		print("Won")
		set_process(false)

func eat_tiles() -> Array:
	return [Vector2i(12, 2), Vector2i(13, 2), Vector2i(14, 2), Vector2i(15, 2)]

func get_enemy_position():
	var position_enemy = map_to_local(Vector2(13, 11))
	return position_enemy

func get_path_to_player():
	var path = NavigationServer2D.map_get_path(get_world_2d().navigation_map, enemy.position, player.position, false)
	return path
