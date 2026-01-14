extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var barrier_collision: CollisionShape2D = $BarrierCollision
@onready var sprite: Sprite2D = $Sprite2D
@onready var barrier_rect: ColorRect = $BarrierRect
@onready var interaction_area: Area2D = $InteractionArea

var is_open: bool = false

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_open:
		return
		
	if body.is_in_group("player"):
		if GameState.use_key():
			open_door()
		else:
			# TODO: Show "Locked" message or sound
			pass

func open_door():
	is_open = true
	# Disable collision
	collision_shape.set_deferred("disabled", true)
	barrier_collision.set_deferred("disabled", true)
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_property(barrier_rect, "modulate:a", 0.0, 0.5)
	# TODO: Play sound
