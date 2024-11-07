extends Control

func _ready():
	print("PauseMenu loaded and ready")

func _on_resume_button_pressed():
	print("Resume button pressed")
	get_tree().paused = false
	queue_free()

func _on_quit_button_pressed():
	print("Quit button pressed")
	get_tree().quit()


func _on_restart_button_pressed():
	print("Restart button pressed")
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")
