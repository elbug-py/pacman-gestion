extends Area2D
var path = []
var direction: Vector2 = Vector2.ZERO
@export var speed: float = 32.0
@export var initial_position: Vector2 = Vector2(0, 0)

# Custom targeting logic (e.g., offset to target position ahead of Pacman)
@export_node_path("TileMap") var walls_path
@onready var walls = get_node(walls_path) as TileMap
@export_node_path("Area2D") var pacman_path
@onready var pacman = get_node(pacman_path) as Area2D

@export var paused: bool = false

func _ready() -> void:
	reset_position()
	await get_tree().process_frame
	set_deferred("path", walls.get_path_to_player())

func reset_position() -> void:
	position = initial_position  # Reset Blinky's position
	path.clear()

func _process(delta: float) -> void:
	if paused:
		return

	if path.size() > 1:
		var position_to_move = path[0]
		direction = (position_to_move - position).normalized()
		var distance = position.distance_to(path[0])
		if distance > 1:
			position += speed * delta * direction
		else:
			path.remove_at(0)
	else:
		path = get_custom_path_to_player()

func get_custom_path_to_player():
	# Custom logic for Pinky's path
	var target_position = pacman.position + Vector2(32, 0)  # Adjust offset as needed
	return NavigationServer2D.map_get_path(get_world_2d().navigation_map, position, target_position, false)

func _on_area_entered(area: Area2D) -> void:
	if area == pacman:
		walls.lose_life()

func pause_movement():
	paused = true

func resume_movement():
	paused = false
