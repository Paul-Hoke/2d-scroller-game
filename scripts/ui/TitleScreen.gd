extends Control

@export var main_game_scene: String = "res://scenes/Main.tscn"

func _ready() -> void:
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(main_game_scene)
