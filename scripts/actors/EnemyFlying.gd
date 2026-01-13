extends CharacterBody2D

@export var speed: float = 100.0
@export var wave_amplitude: float = 50.0
@export var wave_frequency: float = 2.0

var direction: int = -1
var time_passed: float = 0.0
var start_y: float = 0.0
var is_dying: bool = false

@onready var wall_detector: RayCast2D = $WallDetector
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	start_y = global_position.y
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	if animated_sprite.sprite_frames.has_animation("fly"):
		animated_sprite.play("fly")

func _physics_process(delta: float) -> void:
	if is_dying:
		position += velocity * delta
		rotation += 5.0 * delta
		if global_position.y > 2000:
			queue_free()
		return

	time_passed += delta
	
	# Horizontal movement
	velocity.x = direction * speed
	
	# Vertical Sine Wave movement
	var new_y = start_y + sin(time_passed * wave_frequency) * wave_amplitude
	global_position.y = new_y # Directly set position for simple pathing or use velocity.y
	# Using velocity for physics compliance with move_and_slide would be better:
	# velocity.y = (new_y - global_position.y) / delta 
	# But setting position is smoother for strict paths if no collision needed vertically.
	# Let's use direct position for Y, and move_and_slide for X.
	
	# Check walls
	if is_on_wall() or wall_detector.is_colliding():
		direction *= -1
		wall_detector.target_position.x *= -1
	
	# Flip sprite
	animated_sprite.flip_h = direction > 0
	
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dying: return
	
	if body.is_in_group("player"):
		var y_velocity = body.velocity.y
		if y_velocity > 0 and body.global_position.y < global_position.y:
			die()
			body.velocity.y = -300.0
		else:
			GameState.take_damage(1)
			if body.position.x < position.x:
				body.velocity.x = -500
			else:
				body.velocity.x = 500
			body.velocity.y = -200

func die():
	is_dying = true
	GameState.play_kill_sound()
	collision_layer = 0
	collision_mask = 0
	hitbox.monitoring = false
	hitbox.monitorable = false
	velocity.x = 0
	velocity.y = -400.0
