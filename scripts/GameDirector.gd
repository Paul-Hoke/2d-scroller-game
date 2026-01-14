extends Node

var player: Node2D
var goal: Node2D
var spawn_timer: Timer

# Configuration
var spawn_distance: float = 900.0 # Distance ahead of player to spawn
var min_spawn_time: float = 1.0   # Fastest spawn rate (near end)
var max_spawn_time: float = 5.0   # Slowest spawn rate (at start)

# Resources
var enemy_flying_scene = preload("res://scenes/actors/EnemyFlying.tscn")
var enemy_turtle_flying_scene = preload("res://scenes/actors/EnemyFlyingTurtle.tscn")

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = max_spawn_time
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Find Player and Goal in the scene tree
	# We assume this node is added to the Level root (LevelLogic)
	var level_root = get_parent()
	if level_root:
		player = level_root.get_node_or_null("Player")
		goal = level_root.get_node_or_null("Goal")
	
	if player and goal:
		spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if not player or not goal:
		return
		
	# Calculate progress (0.0 to 1.0)
	var start_x = 0.0 # Assuming level starts near 0
	var current_x = player.global_position.x
	var end_x = goal.global_position.x
	
	if end_x <= start_x:
		return # Avoid divide by zero
		
	var progress = clamp((current_x - start_x) / (end_x - start_x), 0.0, 1.0)
	
	# Adjust spawn rate based on progress (Linear interpolation)
	# Progress 0.0 -> max_spawn_time
	# Progress 1.0 -> min_spawn_time
	var new_wait_time = lerp(max_spawn_time, min_spawn_time, progress)
	spawn_timer.wait_time = new_wait_time
	
	# Attempt spawn
	_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy_scene = enemy_flying_scene
	if randf() > 0.5:
		enemy_scene = enemy_turtle_flying_scene
		
	var enemy = enemy_scene.instantiate()
	
	# Position
	var spawn_x = player.global_position.x + spawn_distance
	var spawn_y = randf_range(200, 500) # Random height in gameplay area
	
	enemy.global_position = Vector2(spawn_x, spawn_y)
	
	# Add to the "Enemies" container if it exists, otherwise to level root
	var level_root = get_parent()
	var enemies_node = level_root.get_node_or_null("Enemies")
	if enemies_node:
		enemies_node.add_child(enemy)
	else:
		level_root.add_child(enemy)
