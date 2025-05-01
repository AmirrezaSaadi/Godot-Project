extends Node3D

@export var mouse_sens: float = 0.005
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_vertical_angle = PI/8
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sens
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		
		rotation.x -= event.relative.y * mouse_sens
		rotation.x = clamp(rotation.x, min_vertical_angle, max_vertical_angle)
