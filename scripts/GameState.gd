extends Node

signal score_changed(new_score)
signal health_changed(new_health)

var score: int = 0
var health: int = 3

func reset():
	score = 0
	health = 3
	score_changed.emit(score)
	health_changed.emit(health)

func add_score(amount: int):
	score += amount
	score_changed.emit(score)

func take_damage(amount: int):
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		# Simple restart for now
		call_deferred("restart_game")

func restart_game():
	reset()
	get_tree().reload_current_scene()
