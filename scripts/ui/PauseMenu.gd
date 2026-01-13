extends CanvasLayer

func _ready() -> void:
	# Start hidden
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS # Run even when paused

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_level_select_button_pressed() -> void:
	toggle_pause() # Unpause
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _on_menu_button_pressed() -> void:
	toggle_pause() # Unpause before changing scene
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
