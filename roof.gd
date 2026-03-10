extends Node3D

@export var resolution: int = 120
@export var cell_size: float = 1.0

@export var ground_height: float = 8.0
@export var roof_height: float = 35.0
@export var roof_depth: float = 20.0

var noise: FastNoiseLite

func _ready():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.02
	noise.fractal_octaves = 3

	generate_world()

func generate_world():
	var ground_mesh = generate_ground()
	var roof_mesh = generate_roof()

	$GroundMesh.mesh = ground_mesh
	$RoofMesh.mesh = roof_mesh

	apply_material($GroundMesh, Color(0.3, 0.7, 0.3))
	apply_material($RoofMesh, Color(0.4, 0.4, 0.4))

	create_collision(ground_mesh, $GroundBody/CollisionShape3D)
	create_collision(roof_mesh, $RoofBody/CollisionShape3D)


# ------------------------
# GROUND (plains)
# ------------------------

func generate_ground() -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half = resolution * cell_size / 2.0

	for x in range(resolution):
		for z in range(resolution):
			create_ground_quad(st, x, z, half)

	st.generate_normals()
	return st.commit()

func create_ground_quad(st, x, z, half):
	var x0 = x * cell_size - half
	var x1 = (x + 1) * cell_size - half
	var z0 = z * cell_size - half
	var z1 = (z + 1) * cell_size - half

	var y00 = get_ground_height(x0, z0)
	var y10 = get_ground_height(x1, z0)
	var y01 = get_ground_height(x0, z1)
	var y11 = get_ground_height(x1, z1)

	add_quad(st, x0,y00,z0, x1,y10,z0, x0,y01,z1, x1,y11,z1)


func get_ground_height(x, z):
	var large = noise.get_noise_2d(x * 0.15, z * 0.15)
	var small = noise.get_noise_2d(x * 0.8, z * 0.8) * 0.3
	return (large + small) * ground_height


# ------------------------
# ROOF (reversed mountains)
# ------------------------

func generate_roof() -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half = resolution * cell_size / 2.0

	for x in range(resolution):
		for z in range(resolution):
			create_roof_quad(st, x, z, half)

	st.generate_normals()
	return st.commit()

func create_roof_quad(st, x, z, half):
	var x0 = x * cell_size - half
	var x1 = (x + 1) * cell_size - half
	var z0 = z * cell_size - half
	var z1 = (z + 1) * cell_size - half

	var y00 = get_roof_height(x0, z0)
	var y10 = get_roof_height(x1, z0)
	var y01 = get_roof_height(x0, z1)
	var y11 = get_roof_height(x1, z1)

	add_quad(st, x0,y00,z0, x1,y10,z0, x0,y01,z1, x1,y11,z1)


func get_roof_height(x, z):
	var base = noise.get_noise_2d(x * 0.12, z * 0.12)

	# sharpen mountains
	base = pow(abs(base), 2.5)

	# invert into downward spikes
	base = -base * roof_depth

	return roof_height + base


# ------------------------
# Utility
# ------------------------

func add_quad(st, x0,y0,z0, x1,y1,z0b, x2,y2,z1, x3,y3,z1b):
	var v00 = Vector3(x0,y0,z0)
	var v10 = Vector3(x1,y1,z0b)
	var v01 = Vector3(x2,y2,z1)
	var v11 = Vector3(x3,y3,z1b)

	st.add_vertex(v00)
	st.add_vertex(v10)
	st.add_vertex(v11)

	st.add_vertex(v00)
	st.add_vertex(v11)
	st.add_vertex(v01)


func apply_material(mesh_instance, color):
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	mesh_instance.mesh.surface_set_material(0, mat)


func create_collision(mesh, collision_node):
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(mesh.get_faces())
	collision_node.shape = shape
