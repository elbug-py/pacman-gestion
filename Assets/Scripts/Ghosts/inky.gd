extends Area2D

var path = []
var direction: Vector2 = Vector2.ZERO
@export var speed: float = 32.0
@export var initial_position: Vector2 = Vector2(16, 11)
@export var scared: bool = false
@export var escape_distance: float = 150.0
@export var scared_duration: float = 10.0

@onready var animated_sprite = $AnimatedSprite2D
@export_node_path("TileMap") var walls_path
@onready var walls = get_node(walls_path) as TileMap
@export_node_path("Area2D") var pacman_path
@onready var pacman = get_node(pacman_path) as Area2D
@export_node_path("Area2D") var blinky_path
@onready var blinky = get_node(blinky_path) as Area2D
@export var paused: bool = false
var scared_timer: Timer

func _ready() -> void:
	reset_position()
	setup_scared_timer()
	await get_tree().process_frame
	set_deferred("path", calculate_path())

func setup_scared_timer():
	scared_timer = Timer.new()
	scared_timer.one_shot = true
	scared_timer.timeout.connect(_on_scared_timer_timeout)
	add_child(scared_timer)

func reset_position():
	position = walls.map_to_local(initial_position)
	path.clear()

func _process(delta: float) -> void:
	if paused:
		return
		
	if path.size() <= 1 or (scared and path.size() < 5):
		update_path()
		
	if path.size() > 1:
		var position_to_move = path[0]
		direction = (position_to_move - position).normalized()
		var distance = position.distance_to(path[0])
		
		if distance > 1:
			position += speed * delta * direction
			update_animation()
		else:
			path.remove_at(0)

func calculate_target_position() -> Vector2:
	# Get vector from Blinky to Pac-Man
	var blinky_to_pacman = pacman.position - blinky.position
	# Double the distance
	var target = pacman.position + blinky_to_pacman
	# Clamp to screen bounds
	target.x = clamp(target.x, 0, get_viewport_rect().size.x)
	target.y = clamp(target.y, 0, get_viewport_rect().size.y)
	return target

func update_path():
	if scared:
		var away_vector = (position - pacman.position).normalized()
		var escape_position = position + (away_vector * escape_distance)
		
		escape_position.x = clamp(escape_position.x, 0, get_viewport_rect().size.x)
		escape_position.y = clamp(escape_position.y, 0, get_viewport_rect().size.y)
		
		path = NavigationServer2D.map_get_path(
			get_world_2d().navigation_map,
			position,
			escape_position,
			false
		)
	else:
		path = calculate_path()

func calculate_path() -> Array:
	return NavigationServer2D.map_get_path(
		get_world_2d().navigation_map,
		position,
		calculate_target_position(),
		false
	)

func update_animation():
	if scared:
		animated_sprite.play("scared")
	elif direction.x > 0:
		animated_sprite.play("movingR")
	elif direction.x < 0:
		animated_sprite.play("movingL")

func _on_area_entered(area: Area2D) -> void:
	if area == pacman and scared:
		visible = false
		reset_position()
		await get_tree().create_timer(2.0).timeout
		visible = true
		deactivate_scared_mode()
	elif area == pacman and !scared:
		walls.lose_life()

func pause_movement():
	paused = true

func resume_movement():
	paused = false

func activate_scared_mode():
	scared = true
	speed = speed * 0.75
	update_animation()
	path.clear()
	scared_timer.start(scared_duration)

func deactivate_scared_mode():
	scared = false
	speed = speed / 0.75
	update_animation()
	path.clear()

func _on_scared_timer_timeout():
	if scared:
		deactivate_scared_mode()
