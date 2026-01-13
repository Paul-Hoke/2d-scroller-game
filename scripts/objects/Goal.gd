extends Area2D

@export var next_level_path: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Level Complete!")
		GameState.complete_level()
		if next_level_path != "":
			get_tree().change_scene_to_file(next_level_path)
		else:
			get_tree().change_scene_to_file("res://scenes/ui/Victory.tscn")
