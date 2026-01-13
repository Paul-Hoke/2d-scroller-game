extends Control

@onready var grid = $CenterContainer/VBoxContainer/GridContainer

func _ready():
	get_tree().paused = false
	_generate_buttons()
	$CenterContainer/VBoxContainer/BackButton.grab_focus()

func _generate_buttons():
	for i in 20:
		var level_num = i + 1
		var btn = Button.new()
		btn.text = "Level " + str(level_num)
		btn.custom_minimum_size = Vector2(100, 60)
		
		var path = "res://scenes/Main.tscn"
		if level_num > 1:
			path = "res://scenes/levels/Level" + str(level_num) + ".tscn"
		
		btn.pressed.connect(_on_level_pressed.bind(path))
		grid.add_child(btn)

func _on_level_pressed(path):
	get_tree().paused = false
	get_tree().change_scene_to_file(path)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
