extends Node

signal score_changed(new_score)
signal health_changed(new_health)
signal life_gained()
signal level_changed(new_level_name)
signal keys_changed(count)
signal powerup_obtained(name)

var score: int = 0
var health: int = 3
var current_level_path: String = "res://scenes/Main.tscn"
var current_level_name: String = "1"

var last_life_score: int = 0

# Inventory / Metroidvania logic
var keys: int = 0
var powerups: Dictionary = {
	"double_jump": false
}

# Stats for Victory Screen
var stats_health_gained: int = 0
var stats_health_lost: int = 0
var stats_double_jumps: int = 0
var stats_total_playtime: float = 0.0
var stats_level_completion_times: Array[float] = []

var _level_start_time: float = 0.0

var sfx_kill: AudioStreamPlayer
var sfx_damage: AudioStreamPlayer
var sfx_life: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	sfx_kill = AudioStreamPlayer.new()
	sfx_kill.name = "SFX_Kill"
	sfx_kill.stream = load_wav("res://assets/audio/kill.wav")
	add_child(sfx_kill)
	
	sfx_damage = AudioStreamPlayer.new()
	sfx_damage.name = "SFX_Damage"
	sfx_damage.stream = load_wav("res://assets/audio/damage.wav")
	add_child(sfx_damage)
	
	sfx_life = AudioStreamPlayer.new()
	sfx_life.name = "SFX_Life"
	sfx_life.stream = load_wav("res://assets/audio/life.wav")
	add_child(sfx_life)

func reset():
	score = 0
	health = 3
	last_life_score = 0
	keys = 0
	powerups = {"double_jump": false}
	stats_health_gained = 0
	stats_health_lost = 0
	stats_double_jumps = 0
	stats_total_playtime = 0.0
	stats_level_completion_times = []
	_level_start_time = Time.get_ticks_msec() / 1000.0
	score_changed.emit(score)
	health_changed.emit(health)
	keys_changed.emit(keys)

func start_level_timer():
	_level_start_time = Time.get_ticks_msec() / 1000.0
	keys = 0
	keys_changed.emit(keys)

func complete_level():
	var end_time = Time.get_ticks_msec() / 1000.0
	var duration = end_time - _level_start_time
	stats_level_completion_times.append(duration)
	stats_total_playtime += duration

func add_score(amount: int):
	score += amount
	score_changed.emit(score)
	
	if score >= last_life_score + 100:
		health += 1
		stats_health_gained += 1
		last_life_score += 100
		health_changed.emit(health)
		life_gained.emit()
		sfx_life.play()

func add_key():
	keys += 1
	keys_changed.emit(keys)

func use_key() -> bool:
	if keys > 0:
		keys -= 1
		keys_changed.emit(keys)
		return true
	return false

func add_powerup(p_name: String):
	powerups[p_name] = true
	powerup_obtained.emit(p_name)

func play_kill_sound():
	sfx_kill.play()

func record_double_jump():
	stats_double_jumps += 1

func take_damage(amount: int):
	health -= amount
	stats_health_lost += amount
	health_changed.emit(health)
	sfx_damage.play()
	if health <= 0:
		game_over()

func respawn():
	health -= 1
	stats_health_lost += 1
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

func load_wav(path: String) -> AudioStream:
	var stream = load(path)
	if stream:
		return stream
		
	if not FileAccess.file_exists(path):
		return null
		
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
		
	var bytes = file.get_buffer(file.get_length())
	
	if bytes.slice(0, 4).get_string_from_ascii() != "RIFF":
		return null
		
	var wav = AudioStreamWAV.new()
	
	# Search for 'data' chunk
	var data_idx = -1
	for i in range(12, bytes.size() - 8):
		if bytes[i] == 100 and bytes[i+1] == 97 and bytes[i+2] == 116 and bytes[i+3] == 97: # "data"
			data_idx = i
			break
			
	if data_idx == -1:
		return null
		
	# Search for 'fmt ' chunk
	var fmt_idx = -1
	for i in range(12, bytes.size() - 8):
		if bytes[i] == 102 and bytes[i+1] == 109 and bytes[i+2] == 116 and bytes[i+3] == 32: # "fmt "
			fmt_idx = i
			break
			
	if fmt_idx != -1:
		# Use StreamPeerBuffer to parse integers correctly
		var spb = StreamPeerBuffer.new()
		spb.data_array = bytes
		
		spb.seek(fmt_idx + 10)
		var channels = spb.get_16()
		var sample_rate = spb.get_32()
		spb.seek(fmt_idx + 22)
		var bits = spb.get_16()
		
		spb.seek(data_idx + 4)
		var data_size = spb.get_32()
		
		wav.data = bytes.slice(data_idx + 8, data_idx + 8 + data_size)
		wav.mix_rate = sample_rate
		wav.stereo = (channels == 2)
		wav.format = AudioStreamWAV.FORMAT_16_BITS if bits == 16 else AudioStreamWAV.FORMAT_8_BITS
	else:
		return null
		
	return wav