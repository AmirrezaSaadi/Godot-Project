
extends CharacterBody3D

# Node references
@onready var camera_mount = $camera_mount
@onready var star: Node3D = $"Star/character-female-e"
@onready var animation_tree: AnimationTree = $Star/AnimationPlayer/AnimationTree

# Camera settings
@export var sensitivity: float = 0.05

# Movement properties
@export_category("Locomotion")
@export var _walking_speed: float = 3
@export var _running_speed: float = 6
#@export var _acceleration: float = 4
#@export var _deceleration: float = 8
var _movement_speed: float = _walking_speed

# Jump properties
@export_category("Jumping")
@export var _jump_height: float = 2.5
@export var _mass: float = 1
var _jump_velocity: float

# Constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Initialization
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Input handling
func _input(event: InputEvent) -> void:
	# Mouse camera control
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		star.rotate_y(deg_to_rad(event.relative.x * sensitivity))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
	
	# Action inputs
	if event.is_action_pressed("sprint"):
		run()
	elif event.is_action_released("sprint"):
		walk()
	elif event.is_action_pressed("jump"):
		jump()

# Physics update
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
	animation_tree.set("parameters/Locomotion/blend_position", Vector2(velocity.x, velocity.z).length() / _running_speed)
	
	# Apply movement
	move_and_slide()

# Movement state functions
func walk():
	_movement_speed = _walking_speed
	
func run():
	_movement_speed = _running_speed

func jump():
	if is_on_floor():
		_apply_jump_velocity()
		# _statemachine.travel("jump")

func _apply_jump_velocity():
	velocity.y = _jump_velocity
