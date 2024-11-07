extends Control

func _ready():
	$VBoxContainer/Start.connect("pressed", Callable(self, "_on_start_game_pressed"))
	$VBoxContainer/LevelPicker.connect("pressed", Callable(self, "_on_level_picker_pressed"))
	$VBoxContainer/Quit.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_start_game_pressed():
	load_level("res://Assets/Scenes/Main.tscn")

func _on_level_picker_pressed():
	load_level("res://Assets/Scenes/LvlPicker.tscn")

func _on_quit_pressed():
	get_tree().quit()

func load_level(level_path: String):
	var next_scene = load(level_path).instantiate()
	get_tree().get_root().add_child(next_scene)
	queue_free()  # Close current menu
