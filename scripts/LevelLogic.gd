extends Node2D

func _ready() -> void:
	# Store the current scene path so we can retry it on Game Over
	GameState.current_level_path = scene_file_path
	GameState.start_level_timer()
	
	# Extract level name from path (e.g., "Level3" from "res://scenes/levels/Level3.tscn")
	var level_name = scene_file_path.get_file().get_basename()
	var level_num = 1
	if level_name == "Main":
		level_num = 1
	elif level_name.begins_with("Level"):
		level_num = int(level_name.replace("Level", ""))
	
	GameState.current_level_name = str(level_num)
	GameState.level_changed.emit(str(level_num))
	
	_setup_atmosphere(level_num)

func _setup_atmosphere(level_num: int):
	var theme = "forest"
	if level_num > 15:
		theme = "lava"
	elif level_num > 10:
		theme = "sky"
	elif level_num > 5:
		theme = "cave"
	
	# Setup Music
	var music_player = get_node_or_null("Music")
	if not music_player:
		music_player = AudioStreamPlayer.new()
		music_player.name = "Music"
		add_child(music_player)
	
	var music_path = "res://assets/audio/music_%s.wav" % theme
	if FileAccess.file_exists(music_path):
		music_player.stream = load(music_path)
		music_player.autoplay = true
		music_player.play()
	
	# Setup Background
	var parallax = get_node_or_null("ParallaxBackground")
	if parallax:
		var sprite = parallax.get_node_or_null("BackgroundLayer/Sprite2D")
		if sprite:
			var bg_path = "res://assets/forest_bg_seamless.png"
			if theme != "forest":
				bg_path = "res://assets/bg_%s.png" % theme
			
			var tex = load(bg_path)
			if not tex and FileAccess.file_exists(bg_path):
				# Fallback for missing .import files
				var img = Image.load_from_file(bg_path)
				if img:
					tex = ImageTexture.create_from_image(img)
			
			if tex:
				sprite.texture = tex
	
	# Setup Colors (Floor/Platforms)
	var floor_color = Color(0.27, 0.5, 0.27) # Forest Green
	var plat_color = Color(0.42, 0.36, 0.25) # Brown
	
	match theme:
		"cave":
			floor_color = Color(0.2, 0.2, 0.25) # Dark Blue/Grey
			plat_color = Color(0.1, 0.1, 0.15)
		"sky":
			floor_color = Color(0.7, 0.8, 1.0) # Light Blue
			plat_color = Color(0.9, 0.9, 1.0)
		"lava":
			floor_color = Color(0.4, 0.1, 0.0) # Deep Red
			plat_color = Color(0.2, 0.0, 0.0)
	
	_apply_colors_recursive(self, floor_color, plat_color)
	
	# Setup Colors (Floor/Platforms)
	var floor_color = Color(0.27, 0.5, 0.27) # Forest Green
	var plat_color = Color(0.42, 0.36, 0.25) # Brown
	
	match theme:
		"cave":
			floor_color = Color(0.2, 0.2, 0.25) # Dark Blue/Grey
			plat_color = Color(0.1, 0.1, 0.15)
		"sky":
			floor_color = Color(0.7, 0.8, 1.0) # Light Blue
			plat_color = Color(0.9, 0.9, 1.0)
		"lava":
			floor_color = Color(0.4, 0.1, 0.0) # Deep Red
			plat_color = Color(0.2, 0.0, 0.0)
	
	_apply_colors_recursive(self, floor_color, plat_color)

func _apply_colors_recursive(node: Node, floor_color: Color, plat_color: Color):
	if node is ColorRect:
		if "Floor" in node.get_parent().name:
			node.color = floor_color
		elif "Plat" in node.get_parent().name:
			node.color = plat_color
			
	for child in node.get_children():
		_apply_colors_recursive(child, floor_color, plat_color)
