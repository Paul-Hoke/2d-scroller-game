extends Node2D

func _ready() -> void:
	# Store the current scene path so we can retry it on Game Over
	GameState.current_level_path = scene_file_path
	
	# Extract level name from path (e.g., "Level3" from "res://scenes/levels/Level3.tscn")
	var level_name = scene_file_path.get_file().get_basename()
	if level_name == "Main":
		level_name = "1"
	elif level_name.begins_with("Level"):
		level_name = level_name.replace("Level", "")
	
	GameState.current_level_name = level_name
	GameState.level_changed.emit(level_name)
