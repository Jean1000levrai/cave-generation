@tool
extends MeshInstance3D

const TRI_TABLE = preload("res://scripts/tri_table.gd").TRI_TABLE

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
				
func get_case_index(v: Array) -> int:
# 	     y
#        |
#        4------5
#       /|     /|
#      7------6 |
#      | |    | |
#      | 0----|-1 -> x
#      |/     |/
#      3------2
#     /
#    z
	var case_index := 0

	for i in range(8):
		if v[i] < iso_level:
			case_index |= (1 << i)

	return case_index


func marching_cubes() -> void:
	# loop over all cubes
	for x in range(resolution - 1):
		for y in range(resolution - 1):
			for z in range(resolution - 1):
				# get corner values
				var p = [
					Vector3(x,   y,   z),
					Vector3(x+1, y,   z),
					Vector3(x+1, y,   z+1),
					Vector3(x,   y,   z+1),
					Vector3(x,   y+1, z),
					Vector3(x+1, y+1, z),
					Vector3(x+1, y+1, z+1),
					Vector3(x,   y+1, z+1),
				]

				var v = []
				v.resize(8)

				for i in range(8):
					var pos = p[i]
					v[i] = density_field[pos.x][pos.y][pos.z]
							
				var inside = 0
				var outside = 0
				for i in range(8):
					if v[i] > iso_level:
						outside += 1
					else:
						inside += 1

				# skip cube if it is entirely inside or outside
				if inside == 0 or outside == 0:
					continue

				# gets all edges
				var edge_vertices = []
				edge_vertices.resize(12)
				var edges = [
					[0,1], [1,2], [2,3], [3,0],
					[4,5], [5,6], [6,7], [7,4],
					[0,4], [1,5], [2,6], [3,7]
				]
				for i in range(12):
					var a = edges[i][0]
					var b = edges[i][1]

					var va = v[a]
					var vb = v[b]

					# check if edge is crossed by iso-level
					if (va > iso_level) == (vb > iso_level):
						continue
					
					# interpolation (finds point on edge closest to iso-level)
					# ---------------- COME BACK TO THIS ----------------
					var t = (iso_level - va) / (vb - va)
					edge_vertices[i] = p[a].lerp(p[b], t)

				# -------------------------
				# 4. TRIANGLES (LOOKUP TABLE STAGE)
				# -------------------------
				var case = get_case_index(v)
				print(case)
				var tri = TRI_TABLE[case]
				print(tri)

				var i := 0
				while i < tri.size() and tri[i] != -1:
					var a = tri[i]
					var b = tri[i + 1]
					var c = tri[i + 2]

					if edge_vertices[a] == null or edge_vertices[b] == null or edge_vertices[c] == null:
						i += 3
						continue

					var base = vertices.size()

					vertices.append(edge_vertices[a])
					vertices.append(edge_vertices[b])
					vertices.append(edge_vertices[c])

					indices.append(base)
					indices.append(base + 1)
					indices.append(base + 2)

					i += 3
			
				
				
func generate_mesh() -> void:
	var verts = PackedVector3Array(vertices)
	var inds = PackedInt32Array(indices)

	var mesh_array = []
	mesh_array.resize(Mesh.ARRAY_MAX)

	mesh_array[Mesh.ARRAY_VERTEX] = verts
	mesh_array[Mesh.ARRAY_INDEX] = inds

	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)

	mesh = array_mesh

func update_mesh() -> void:
	vertices.clear()
	indices.clear()

	# 1. gen density field
	generate_density_field()

	# 2. marching cubes
	marching_cubes()

	# 3. build mesh
	generate_mesh()
