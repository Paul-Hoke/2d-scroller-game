extends CharacterBody2D

@export var speed: float = 60.0
@export var gravity: float = 980.0

var direction: int = -1
var is_dying: bool = false

@onready var wall_detector: RayCast2D = $WallDetector
@onready var floor_detector: RayCast2D = $FloorDetector
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	animated_sprite.play("walk")

func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += gravity * delta
	
	if is_dying:
		# Simple physics for falling off screen
		position += velocity * delta
		
		# Rotate the sprite for a "tumble" effect
		rotation += 5.0 * delta
		
		# Remove when far below the map
		if global_position.y > 2000:
			queue_free()
		return

	# Normal AI logic
	if is_on_wall() or wall_detector.is_colliding() or not floor_detector.is_colliding():
		direction *= -1
		wall_detector.target_position.x *= -1
		floor_detector.position.x = abs(floor_detector.position.x) * direction
	
	velocity.x = direction * speed
	animated_sprite.flip_h = direction > 0 # Assuming sprite faces left by default? Or right? Usually right.
	# If sprite faces right by default:
	# direction 1 (right) -> flip_h = false
	# direction -1 (left) -> flip_h = true
	# Let's adjust based on the image. If image faces right:
	animated_sprite.flip_h = direction < 0
	
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dying: return
	
	if body.is_in_group("player"):
		var y_velocity = body.velocity.y
		# If player is falling and above the enemy
		if y_velocity > 0 and body.global_position.y < global_position.y:
			die()
			body.velocity.y = -300.0 # Bounce
		else:
			# Damage player
			GameState.take_damage(1)
			# Knockback
			if body.position.x < position.x:
				body.velocity.x = -500
			else:
				body.velocity.x = 500
			body.velocity.y = -200

func die():
	is_dying = true
	
	# Disable collisions
	collision_layer = 0
	collision_mask = 0
	hitbox.monitoring = false
	hitbox.monitorable = false
	
	# Bounce up
	velocity.x = 0
	velocity.y = -400.0