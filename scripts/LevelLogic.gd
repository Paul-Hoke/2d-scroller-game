extends Node2D

func _ready() -> void:
	# Store the current scene path so we can retry it on Game Over
	GameState.current_level_path = scene_file_path
