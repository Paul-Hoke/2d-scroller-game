extends Node

signal score_changed(new_score)
signal health_changed(new_health)
signal level_changed(new_level_name)

var score: int = 0
var health: int = 3
var current_level_path: String = "res://scenes/Main.tscn"
var current_level_name: String = "1"

var sfx_kill: AudioStreamPlayer
var sfx_damage: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Ensure global state works even when paused, though audio usually does.
	
	sfx_kill = AudioStreamPlayer.new()
	sfx_kill.stream = load("res://assets/audio/kill.wav")
	add_child(sfx_kill)
	
	sfx_damage = AudioStreamPlayer.new()
	sfx_damage.stream = load("res://assets/audio/damage.wav")
	add_child(sfx_damage)

func reset():
	score = 0
	health = 3
	score_changed.emit(score)
	health_changed.emit(health)

func add_score(amount: int):
	score += amount
	score_changed.emit(score)

func play_kill_sound():
	sfx_kill.play()

func take_damage(amount: int):
	health -= amount
	health_changed.emit(health)
	sfx_damage.play()
	if health <= 0:
		game_over()

func respawn():
	health -= 1
	health_changed.emit(health)
	sfx_damage.play()
	if health <= 0:
		game_over()
	else:
		get_tree().reload_current_scene()

func game_over():
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

func restart_game():
	reset()
	get_tree().reload_current_scene()
