extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var max_jumps: int = 2
@export var death_y_threshold: float = 1000.0

var jump_count: int = 0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	GameState.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: int) -> void:
	# Flash red
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _physics_process(delta: float) -> void:
	# Check for falling off the level
	if global_position.y > death_y_threshold:
		GameState.respawn()

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or jump_count < max_jumps:
			velocity.y = jump_velocity
			jump_count += 1
			if jump_count == 2:
				GameState.record_double_jump()
			$JumpSound.play()

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		animated_sprite.play("idle")
	
	if not is_on_floor():
		animated_sprite.play("jump")

	move_and_slide()

func reset_jumps():
	jump_count = 0
