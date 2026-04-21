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
				

func marching_cubes() -> void:
	# loop over all cubes
	for x in range(resolution - 1):
		for y in range(resolution - 1):
			for z in range(resolution - 1):
				# get corner values
				var state_of_cube := true    # false: air or solid, true: mixed
				var cube_corners = []
				for i in range(2):
					for j in range(2):
						for k in range(2):
							cube_corners.append(density_field[x+i][y+j][z+k])
							
				# checks if cube is mixed or not
				for i in range(6):
					state_of_cube = not (cube_corners[i] == cube_corners[i+1])
					if state_of_cube: break
					
				if state_of_cube:
					# interpolation TODO
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
