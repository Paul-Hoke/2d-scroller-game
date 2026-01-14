extends Area2D

@export var powerup_name: String = "double_jump"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.add_powerup(powerup_name)
		# TODO: Play powerup sound
		queue_free()
