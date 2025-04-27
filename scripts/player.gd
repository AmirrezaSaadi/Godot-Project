extends CharacterBody3D

# Node references
@onready var camera_mount = $camera_mount
@onready var star: Node3D = $"Star/character-female-e"
@onready var animation_tree: AnimationTree = $Star/AnimationPlayer/AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

# Camera settings
@export var sensitivity: float = 0.05

# Movement properties
@export_category("Locomotion")
@export var walking_speed: float = 3
@export var running_speed: float = 6
var _movement_speed: float

# Jump properties
@export_category("Jumping")
@export var jump_height: float = 2.5
@export var mass: float = 1
var _jump_velocity: float

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Initialization
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_movement_speed = walking_speed
	_jump_velocity = sqrt(jump_height * _gravity * mass * 2)

# Input handling
func _input(event: InputEvent) -> void:
	# Mouse camera control
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		star.rotate_y(deg_to_rad(event.relative.x * sensitivity))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
	
	# Action inputs
	if event.is_action_pressed("sprint"):
		_run()
	elif event.is_action_released("sprint"):
		_walk()
	elif event.is_action_pressed("jump"):
		_jump()

# Physics update
func _physics_process(delta: float) -> void:
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= _gravity * mass * delta

	# Calculate movement direction from input
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply movement or deceleration
	if direction:
		# Orient character model toward movement direction
		star.look_at(star.global_transform.origin + -direction, Vector3.UP)
		velocity.x = direction.x * _movement_speed
		velocity.z = direction.z * _movement_speed
	else:
		# Slow down when no input
		velocity.x = move_toward(velocity.x, 0, _movement_speed)
		velocity.z = move_toward(velocity.z, 0, _movement_speed)
	
	# Update animation based on movement speed
	animation_tree.set("parameters/Locomotion/blend_position", Vector2(velocity.x, velocity.z).length() / running_speed)
	
	# Apply movement
	move_and_slide()

# Movement state functions
func _walk():
	_movement_speed = walking_speed
	
func _run():
	_movement_speed = running_speed

func _jump():
	if is_on_floor():
		_apply_jump_velocity()
		state_machine.travel("jump")

func _apply_jump_velocity():
	velocity.y = _jump_velocity
