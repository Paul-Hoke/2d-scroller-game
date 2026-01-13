extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var max_jumps: int = 2

var jump_count: int = 0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or jump_count < max_jumps:
			velocity.y = jump_velocity
			jump_count += 1
			$JumpSound.play()

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
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
