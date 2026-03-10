extends Node3D


@export var size := 50      # number of points along X and Z
@export var height := 20.0  # maximum height
@export var frequency := 0.05

var noise := FastNoiseLite.new()

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = 1234
	noise.frequency = 0.01
	
	generate_mesh()

	for x in range(5):
		for y in range(5):
			var value = noise.get_noise_2d(x, y)
			print(value)


func generate_mesh():
	var mesh_instance = $GroundMesh
	if mesh_instance == null:
		print("no mesh instance")
		return

	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
		
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	
	# 1) Vertices
	for x in range(size):
		for z in range(size):
			var n = noise.get_noise_2d(x, z)
			var y = n * height
			vertices.append(Vector3(x, y, z))
	
	# 2) Triangles
	for x in range(size - 1):
		for z in range(size - 1):
			var i = x * size + z
			indices.append_array([
				i, i + 1, i + size,
				i + 1, i + size + 1, i + size
			])
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	# Assign to child
	mesh_instance.mesh = mesh
