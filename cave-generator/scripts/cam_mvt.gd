extends Node3D

@export var sensitivity := 0.002
@export var speed := 5.0
@export var min_pitch := deg_to_rad(-80)
@export var max_pitch := deg_to_rad(80)

@onready var camera: Camera3D = $Camera3D

var pitch := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)

		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, min_pitch, max_pitch)

		camera.rotation.x = pitch

func _process(delta):
	var input_dir := Vector3.ZERO

	if Input.is_action_pressed("cam_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("cam_backward"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("cam_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("cam_right"):
		input_dir += transform.basis.x

	# NEW: vertical movement (world up/down)
	if Input.is_action_pressed("cam_up"):
		input_dir += Vector3.UP
	if Input.is_action_pressed("cam_down"):
		input_dir -= Vector3.UP

	input_dir = input_dir.normalized()

	position += input_dir * speed * delta
