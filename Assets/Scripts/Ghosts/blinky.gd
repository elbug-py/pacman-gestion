extends Area2D

var path = []
var direction: Vector2 = Vector2.ZERO
@export var speed: float = 34.0
@export var initial_position: Vector2 = Vector2(13, 11) 
# Get nodes
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
		path = walls.get_path_to_player()

func _on_area_entered(area: Area2D) -> void:
	if area == pacman:
		walls.lose_life()

func pause_movement():
	paused = true

func resume_movement():
	paused = false
