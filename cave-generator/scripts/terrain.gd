@tool
extends MeshInstance3D

@export var size := 256.0

@export_range(4, 256, 4) var resolution := 32:
	set(new_resolution):
		resolution = new_resolution
		update_mesh()

@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_mesh()
		if noise:
			noise.changed.connect(update_mesh)

@export_range(4.0, 128.0, 4.0) var height := 64.0:
	set(new_height):
		height = new_height
		update_mesh()

func update_mesh() -> void:
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size, size)
	
	var plane_array :=  plane.get_mesh_arrays()
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_array)
	mesh = array_mesh
