extends Area2D

var path = []
var direction: Vector2 = Vector2.ZERO
@export var speed: float = 34.0

# Get nodes
@export_node_path("TileMap") var walls_path
@onready var walls = get_node(walls_path) as TileMap

func _ready() -> void:
	position = walls.get_enemy_position()
	await get_tree().process_frame
	set_deferred("path", walls.get_path_to_player())

func _process(delta: float) -> void:
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
	print(area.name)
