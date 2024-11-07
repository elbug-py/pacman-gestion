extends Control

func _ready():
	# Assuming buttons are named Level1Button, Level2Button, etc.
	$GridContainer/Lvl1.connect("pressed", Callable(self, "_on_level1_pressed"))
	$GridContainer/Lvl2.connect("pressed", Callable(self, "_on_level2_pressed"))
	$GridContainer/Lvl3.connect("pressed", Callable(self, "_on_level3_pressed"))

	# Repeat for additional levels

func _on_level1_pressed():
	load_level("res://Assets/Scenes/Main.tscn")

func _on_level2_pressed():
	load_level("res://Assets/Scenes/Main2.tscn")

func _on_level3_pressed():
	load_level("res://Assets/Scenes/Main3.tscn")

func load_level(level_path: String):
	var next_scene = load(level_path).instantiate()
	get_tree().get_root().add_child(next_scene)
	queue_free()  # Close level picker menu
