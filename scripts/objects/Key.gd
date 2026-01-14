extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.add_key()
		# TODO: Play specific key sound
		# GameState.sfx_life.play() # Placeholder
		queue_free()
