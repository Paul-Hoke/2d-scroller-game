extends Control

@onready var score_label: Label = $VBoxContainer/ScoreLabel

func _ready() -> void:
	score_label.text = "Final Score: " + str(GameState.score)

func _on_menu_button_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
