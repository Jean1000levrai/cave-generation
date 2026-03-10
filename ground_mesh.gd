extends MeshInstance3D



@export var size := 50      # number of points along X and Z
@export var height := 20.0  # maximum height
@export var frequency := 0.05

var noise := FastNoiseLite.new()

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = 1234
	noise.frequency = 0.01

	for x in range(5):
		for y in range(5):
			var value = noise.get_noise_2d(x, y)
			print(value)


func generate_mesh():
	var mesh1 = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
		
	# 1) Generate vertices
	for x in range(size):
		for z in range(size):
			var n = noise.get_noise_2d(x, z)	  # Perlin noise
			var y = n * height					 # scale to terrain height
			vertices.append(Vector3(x, y, z))

	# 2) Generate triangle indices
	for x in range(size - 1):
		for z in range(size - 1):
			var i = x * size + z
			indices.append_array([
				i, i + 1, i + size,
				i + 1, i + size + 1, i + size
			])
		
	# 3) Build mesh
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh1.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		
	self.mesh1 = mesh1
