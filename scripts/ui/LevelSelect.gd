extends Control

@onready var grid = $CenterContainer/VBoxContainer/GridContainer

func _ready() -> void:
	get_tree().paused = false # Force unpause to ensure UI works
	_generate_level_buttons()
	$CenterContainer/VBoxContainer/BackButton.grab_focus()

func _generate_level_buttons():
	for i in range(1, 21):
		var btn = Button.new()
		btn.text = "Level " + str(i)
		btn.custom_minimum_size = Vector2(100, 60)
		btn.theme_override_font_sizes/font_size = 18
		
		var level_path = ""
		if i == 1:
			level_path = "res://scenes/Main.tscn"
		else:
			level_path = "res://scenes/levels/Level" + str(i) + ".tscn"
			
		btn.pressed.connect(_on_level_button_pressed.bind(level_path))
		grid.add_child(btn)

func _on_level_button_pressed(path: String):
	get_tree().paused = false # Ensure game is unpaused if coming from pause menu
	get_tree().change_scene_to_file(path)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
