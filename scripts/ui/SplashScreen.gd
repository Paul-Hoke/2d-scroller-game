extends Control

@export var title_screen_path: String = "res://scenes/ui/TitleScreen.tscn"
@export var display_time: float = 5.0

var elapsed_time: float = 0.0

func _ready() -> void:
	# Fade in animation
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

func _process(delta: float) -> void:
	elapsed_time += delta

	# Check for skip inputs
	if Input.is_action_just_pressed("ui_accept") or \
	   Input.is_action_just_pressed("ui_cancel") or \
	   Input.is_action_just_pressed("pause"):
		_go_to_title_screen()
		return

	# Auto-advance after display time
	if elapsed_time >= display_time:
		_go_to_title_screen()

func _go_to_title_screen() -> void:
	# Fade out before transition
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file(title_screen_path))
