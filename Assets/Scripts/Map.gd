extends TileMap
signal area_eat(tile_eat: bool)

@export var initial_lives: int = 3
@export var score: int = 0
var lives: int

@export_node_path("Area2D") var player_path
@onready var pacman = get_node(player_path) as Area2D
@export_node_path("Area2D") var enemy_path
@onready var blinky = get_node(enemy_path) as Area2D
@export_node_path("Area2D") var enemy2_path
@onready var pinky = get_node(enemy2_path) as Area2D
@export_node_path("TileMap") var walls_path
@onready var walls = get_node(walls_path) as TileMap
@export_node_path("Label") var lives_label_path
@export_node_path("Label") var score_label_path
@onready var lives_label = get_node(lives_label_path) as Label
@onready var score_label = get_node(score_label_path) as Label

func _ready():
	print(player_path)
	lives = initial_lives
	score = 0
	update_labels()

func reset_positions():
	pacman.position = walls.get_initialize_position()
	blinky.reset_position()
	pinky.reset_position()

func lose_life():
	lives -= 1
	update_labels()
	print("Remaining lives: ", lives)
	if lives > 0:
		blinky.pause_movement()
		pinky.pause_movement()
		
		await pacman.play_death_animation()
		
		reset_positions()
		
		blinky.resume_movement()
		pinky.resume_movement()
	else:
		game_over()

func game_over():
	print("You Lose")

func get_initialize_position():
	var position_map = map_to_local(Vector2(14, 23))
	return position_map

func is_tile_vacant(position_pacman: Vector2i, direction: Vector2i):
	var next_tile_position: Vector2 = Vector2.LEFT
	var current_tile = local_to_map(position_pacman)
	var next_tile = get_cell_atlas_coords(0, current_tile + direction)
	if next_tile in eat_tiles():
		next_tile_position = map_to_local(current_tile + direction)
		area_eat.emit(true)
	elif next_tile in big_dot_tiles():
		next_tile_position = map_to_local(current_tile + direction)
		area_eat.emit(true)
	else:
		area_eat.emit(false)
		next_tile_position = relocate(position_pacman)
	
	return next_tile_position

func relocate(position_pacman: Vector2):
	var tile_position = local_to_map(position_pacman)
	return map_to_local(tile_position)

func big_dot_tiles() -> Array:
	return [Vector2i(14, 2)]

func eat(position_pacman: Vector2):
	var current_tile = local_to_map(position_pacman)
	var tile = get_cell_atlas_coords(0, current_tile)
	if tile == Vector2i(12, 2):
		return
	if tile in eat_tiles():
		set_cell(0, current_tile, 0, Vector2i(12, 2))
		score += 100
	elif tile in big_dot_tiles():
		set_cell(0, current_tile, 0, Vector2i(12, 2))
		score += 1000
	update_labels()

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
	return [Vector2i(12, 2), Vector2i(13, 2)]

func get_path_to_player():
	var path = NavigationServer2D.map_get_path(get_world_2d().navigation_map, blinky.position, pacman.position, false)
	return path

func update_labels():
	lives_label.text = "Lives: " + str(lives)
	score_label.text = "Score: " + str(score)
