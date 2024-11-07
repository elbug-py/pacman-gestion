extends Area2D

var next_movement_direction: Vector2 = Vector2.LEFT
var tile_wall: bool = true
var movement_direction: Vector2 = Vector2.LEFT
@export var speed: int = 8

# Get Nodes.
@onready var sprite_anim: AnimatedSprite2D = $Sprite
@export_node_path("TileMap") var walls_path
@onready var walls = get_node(walls_path) as TileMap
@onready var walls_detector_raycast: RayCast2D = $WallsDetectorRaycast

var is_dying: bool = false

func _ready() -> void:
	position = walls.get_initialize_position()
	walls.connect("area_eat", eating)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("Up"):
		next_movement_direction = Vector2.UP
		walls_detector_raycast.target_position = Vector2.UP * 5
	elif Input.is_action_pressed("Down"):
		next_movement_direction = Vector2.DOWN
		walls_detector_raycast.target_position = Vector2.DOWN * 5
	elif Input.is_action_pressed("Left"):
		next_movement_direction = Vector2.LEFT
		walls_detector_raycast.target_position = Vector2.LEFT * 5
	elif Input.is_action_pressed("Right"):
		next_movement_direction = Vector2.RIGHT
		walls_detector_raycast.target_position = Vector2.RIGHT * 5

func _process(delta: float) -> void:

	if is_dying:
		return

	if movement_direction == Vector2.ZERO || !is_wall():
		sprite_anim.look_at(movement_direction + position)
		movement_direction = next_movement_direction

	walls.eat(position)
	position = position.lerp(walls.is_tile_vacant(position, movement_direction), speed * delta)

func eating(tile_eat: bool):
	if tile_eat:
		sprite_anim.play("moving")
	else:
		sprite_anim.pause()

func set_direction(direction_pacman: Vector2, forced: bool = false):
	next_movement_direction = direction_pacman

func is_wall() -> bool:
	var wall = walls_detector_raycast.get_collider()
	return wall != null

func play_death_animation():
	is_dying = true
	sprite_anim.play("death")  # Assuming "death" is the name of the death animation in AnimatedSprite2D
	await sprite_anim.animation_finished
	is_dying = false
	walls.reset_positions()
	sprite_anim.play("moving")

