extends RigidBody

export (float, 0, 10000) var speed = 60.0
export (float, 10, 100) var max_distance = 30.0

var start_transform : Transform
var can_fire = true

func _ready():
	# ignore parent transform - all transform are global space
	set_as_toplevel(true)


func _process(delta):
	# Destroy when max distance reached
	if ((global_transform.origin - start_transform.origin).length() >= max_distance):
		print ("MAX DISTANCE REACHED!")
		queue_free()


func fire(spawn_transform : Transform):
	start_transform = spawn_transform
	global_transform = start_transform
	linear_velocity = -spawn_transform.basis.z * speed


func _on_Bullet_body_entered(body):
	print ("HIT!")
	queue_free()
