extends Area2D

@export var value: int = 10

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.add_score(value)
		# Defer removal to avoid issues during physics callback
		call_deferred("queue_free")
