extends Control

@onready var grid = $CenterContainer/VBoxContainer/GridContainer

func _ready():
	get_tree().paused = false
	_generate_buttons()
	$CenterContainer/VBoxContainer/BackButton.grab_focus()

func _generate_buttons():
	for i in 20:
		var level_num = i + 1

		# Create button container with preview background
		var container = PanelContainer.new()
		container.custom_minimum_size = Vector2(140, 100)

		# Create stylebox for the panel background based on theme
		var theme_color = _get_theme_color(level_num)
		var style = StyleBoxFlat.new()
		style.bg_color = theme_color
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.3, 0.3, 0.3, 1)

		container.add_theme_stylebox_override("panel", style)

		# Create VBox for layout
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		container.add_child(vbox)

		# Add theme label
		var theme_label = Label.new()
		theme_label.text = _get_theme_name(level_num)
		theme_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		theme_label.add_theme_font_size_override("font_size", 12)
		theme_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
		theme_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		theme_label.add_theme_constant_override("shadow_offset_x", 1)
		theme_label.add_theme_constant_override("shadow_offset_y", 1)
		vbox.add_child(theme_label)

		# Add button
		var btn = Button.new()
		btn.text = "Level " + str(level_num)
		btn.custom_minimum_size = Vector2(120, 40)

		var path = "res://scenes/Main.tscn"
		if level_num > 1:
			path = "res://scenes/levels/Level" + str(level_num) + ".tscn"

		btn.pressed.connect(_on_level_pressed.bind(path))
		vbox.add_child(btn)

		grid.add_child(container)

func _on_level_pressed(path):
	get_tree().paused = false
	get_tree().change_scene_to_file(path)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")

func _get_theme_name(level_num: int) -> String:
	if level_num > 15:
		return "🔥 Lava"
	elif level_num > 10:
		return "☁️ Sky"
	elif level_num > 5:
		return "🗻 Cave"
	else:
		return "🌲 Forest"

func _get_theme_color(level_num: int) -> Color:
	if level_num > 15:
		# Lava theme - red/orange
		return Color(0.5, 0.15, 0.1, 1)
	elif level_num > 10:
		# Sky theme - blue/white
		return Color(0.4, 0.6, 0.9, 1)
	elif level_num > 5:
		# Cave theme - gray/dark
		return Color(0.25, 0.25, 0.3, 1)
	else:
		# Forest theme - green/brown
		return Color(0.3, 0.5, 0.3, 1)
