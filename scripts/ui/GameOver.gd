extends Control

func _ready() -> void:
	$VBoxContainer/RetryButton.grab_focus()

func _on_retry_button_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file(GameState.current_level_path)

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
