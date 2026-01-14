extends Node2D

func _ready() -> void:
	GameState.current_level_path = scene_file_path
	GameState.start_level_timer()
	
	var level_id = scene_file_path.get_file().get_basename()
	if level_id == "":
		level_id = name
		
	var level_num = 1
	if level_id == "Main":
		level_num = 1
	elif level_id.begins_with("Level"):
		level_num = int(level_id.replace("Level", ""))
	
	GameState.current_level_name = str(level_num)
	GameState.level_changed.emit(str(level_num))
	
	_setup_atmosphere(level_num)
	
	# Add Dynamic Game Director
	var director_script = load("res://scripts/GameDirector.gd")
	if director_script:
		var director = Node.new()
		director.name = "GameDirector"
		director.set_script(director_script)
		add_child(director)

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
		music_player.process_mode = Node.PROCESS_MODE_ALWAYS # Ensure it plays
		add_child(music_player)
	
	var music_path = "res://assets/audio/music_%s.wav" % theme
	var stream = GameState.load_wav(music_path)
	if stream:
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music_player.stream = stream
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
				var img = Image.load_from_file(bg_path)
				if img:
					tex = ImageTexture.create_from_image(img)
			
			if tex:
				sprite.texture = tex
	
	# Setup Colors (Floor/Platforms)
	var floor_color = Color(0.27, 0.5, 0.27)
	var plat_color = Color(0.42, 0.36, 0.25)
	
	match theme:
		"cave":
			floor_color = Color(0.2, 0.2, 0.25)
			plat_color = Color(0.1, 0.1, 0.15)
		"sky":
			floor_color = Color(0.7, 0.8, 1.0)
			plat_color = Color(0.9, 0.9, 1.0)
		"lava":
			floor_color = Color(0.4, 0.1, 0.0)
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