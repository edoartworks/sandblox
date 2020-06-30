extends RigidBody

export (float, 0, 10000) var speed = 60.0
export (float, 10, 100) var max_distance = 50.0

var can_fire = true

func _ready():
	# ignore parent transform - all transform are global space
	set_as_toplevel(true)

func fire(spawn_transform : Transform):
	global_transform = spawn_transform
	linear_velocity = -spawn_transform.basis.z * speed
