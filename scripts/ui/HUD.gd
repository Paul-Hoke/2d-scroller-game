extends CanvasLayer

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthLabel

func _ready() -> void:
	# Connect to GameState signals
	GameState.score_changed.connect(_on_score_changed)
	GameState.health_changed.connect(_on_health_changed)
	
	# Initialize labels
	_on_score_changed(GameState.score)
	_on_health_changed(GameState.health)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)

func _on_health_changed(new_health: int) -> void:
	health_label.text = "Health: " + str(new_health)
