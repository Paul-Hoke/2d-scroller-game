extends Control

@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var health_gained_value: Label = $VBoxContainer/StatsGrid/HealthGainedValue
@onready var health_lost_value: Label = $VBoxContainer/StatsGrid/HealthLostValue
@onready var double_jumps_value: Label = $VBoxContainer/StatsGrid/DoubleJumpsValue
@onready var playtime_value: Label = $VBoxContainer/StatsGrid/PlaytimeValue
@onready var avg_time_value: Label = $VBoxContainer/StatsGrid/AvgTimeValue

func _ready() -> void:
	score_label.text = "Final Score: " + str(GameState.score)
	health_gained_value.text = str(GameState.stats_health_gained)
	health_lost_value.text = str(GameState.stats_health_lost)
	double_jumps_value.text = str(GameState.stats_double_jumps)
	playtime_value.text = "%.1fs" % GameState.stats_total_playtime
	
	var avg = 0.0
	if not GameState.stats_level_completion_times.is_empty():
		var total = 0.0
		for t in GameState.stats_level_completion_times:
			total += t
		avg = total / GameState.stats_level_completion_times.size()
	
	avg_time_value.text = "%.1fs" % avg
	
	$VBoxContainer/MenuButton.grab_focus()

func _on_menu_button_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
