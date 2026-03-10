extends Camera3D

@export var speed := 10.0
@export var fast_speed := 25.0
@export var mouse_sensitivity := 0.002

var velocity := Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity)

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	var current_speed = speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = fast_speed

	var direction = Vector3.ZERO

	if Input.is_key_pressed(KEY_Z):
		direction -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		direction += transform.basis.z
	if Input.is_key_pressed(KEY_Q):
		direction -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		direction += transform.basis.x
	if Input.is_key_pressed(KEY_A):
		direction += transform.basis.y
	if Input.is_key_pressed(KEY_E):
		direction -= transform.basis.y

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	translate(direction * current_speed * delta)
