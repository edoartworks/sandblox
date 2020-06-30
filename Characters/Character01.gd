extends KinematicBody

export var speed : float = 20
export var acceleration : float = 15
export var air_acceleration : float = 5  # to limit air control
export var gravity : float = 0.98
export var max_terminal_velocity : float = 54
export var jump_power : float = 20

export (float, 0.1, 1) var mouse_sensitivity_x : float = 0.3
export (float, 0.1, 1) var mouse_sensitivity_y : float = 0.2
export (float, -90, 0) var min_pitch : float = -75
export (float, 0, 90) var max_pitch : float = 75

var velocity : Vector3
var y_velocity : float  # makes easier to control Y vel without messin the others

onready var camera_pivot = $CameraPivot
onready var camera = $CameraPivot/SpringArm/Camera
onready var primary_fire_locator = $PrimaryFire_Loc

export (PackedScene) var ability_primary = preload("res://Abilities/PrimaryFire/Bullet.tscn")

func _ready():
	# capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta):
	# release mouse on esc
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	handle_movement(delta)

func _input(event):

	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("fire_primary"):
			fire_primary()
		
		# capture mouse if clicking while not captured
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# player and camera rotation
	if event is InputEventMouseMotion:
		# separate rotations to avoid issues
		# X is done on the camera and Y on the character
		camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity_y
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, min_pitch, max_pitch)
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_x

func fire_primary():
	var fire_transform = primary_fire_locator.get_global_transform()
	var primary_fire = ability_primary.instance()
	
	primary_fire_locator.add_child(primary_fire)
	primary_fire.fire(fire_transform)


func handle_movement(delta):
	var direction = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z  # -Z is forward in Godot
	
	if Input.is_action_pressed("move_backwards"):
		direction += transform.basis.z
	
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
		
	direction = direction.normalized()
	
	# acceleration
	var accel = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	
	# gravity
	if not is_on_floor():
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)
	
	# jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y_velocity = jump_power
	
	# apply velocities
	velocity.y = y_velocity
	velocity = move_and_slide(velocity, Vector3.UP)
