extends Area2D

@export var value: int = 10

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.add_score(value)
		# Add a nice little tween for feedback before deleting?
		# For now, just disappear.
		queue_free()
