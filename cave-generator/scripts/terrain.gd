@tool
extends MeshInstance3D

@export var grid_size := 256.0:
	set(new_grid_size):
		grid_size = new_grid_size
		update_mesh()
@export var iso_level := 0.0:
	set(new_iso_level):
		iso_level = new_iso_level
		update_mesh()

@export_range(4, 256, 4) var resolution := 8:
	set(new_resolution):
		resolution = new_resolution
		update_mesh()
@export var frequency := 0.1:
	set(new_frequency):
		frequency = new_frequency
		update_mesh()
@export var noise: FastNoiseLite = FastNoiseLite.new():
	set(new_noise):
		noise = new_noise
		update_mesh()
		if noise:
			noise.changed.connect(update_mesh)
@export var noise_seed := 0:
	set(new_seed):
		noise_seed = new_seed
		noise.seed = noise_seed
		update_mesh()


var density_field = []   # 3D data storage
var vertices = []
var indices = []

func generate_density_field() -> void:
	density_field.resize(resolution)

	for x in range(resolution):
		density_field[x] = []
		density_field[x].resize(resolution)

		for y in range(resolution):
			density_field[x][y] = []
			density_field[x][y].resize(resolution)

			for z in range(resolution):
				var value = noise.get_noise_3d(x, y, z)
				density_field[x][y][z] = value

				print(value)

				var cube = MeshInstance3D.new()
				cube.mesh = BoxMesh.new()
				cube.position = Vector3(x, y, z)
				add_child(cube)
				

func marching_cubes() -> void:
	pass

func generate_mesh() -> void:
	pass

func update_mesh() -> void:
	vertices.clear()
	indices.clear()

	# 1. gen density field
	generate_density_field()

	# 2. marching cubes
	marching_cubes()

	# 3. build mesh
	generate_mesh()
