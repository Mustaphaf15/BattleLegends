extends Node3D

## Original procedural mobile forest: no textures or third-party resources.
## Five MultiMeshes share six materials; 88 decorative instances, <7k triangles.
var instance_budget := 0
var triangle_budget := 0
var material_count := 0

func material(color: Color, glow := false) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = color
    result.roughness = 0.9
    if glow:
        result.emission_enabled = true
        result.emission = color * 0.55
    material_count += 1
    return result

func group_mesh(title: String, mesh: Mesh, positions: Array[Vector3], scales: Array[Vector3]) -> void:
    var instances := MultiMesh.new()
    instances.transform_format = MultiMesh.TRANSFORM_3D
    instances.mesh = mesh
    instances.instance_count = positions.size()
    for index in positions.size():
        instances.set_instance_transform(index, Transform3D(Basis.from_scale(scales[index]), positions[index]))
    var group := MultiMeshInstance3D.new()
    group.name = title
    group.multimesh = instances
    group.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(group)
    instance_budget += positions.size()
    triangle_budget += positions.size() * (mesh.get_faces().size() / 3)

func _ready() -> void:
    var bark := material(Color(0.16, 0.22, 0.24))
    var leaves := material(Color(0.09, 0.28, 0.26))
    var stone := material(Color(0.24, 0.31, 0.36))
    var fern := material(Color(0.16, 0.46, 0.34))
    var crystal := material(Color(0.3, 0.36, 0.8), true)
    var positions: Array[Vector3] = []
    var scales: Array[Vector3] = []
    var trunk := CylinderMesh.new()
    trunk.top_radius = 0.22
    trunk.bottom_radius = 0.38
    trunk.height = 5.0
    trunk.radial_segments = 7
    trunk.rings = 1
    trunk.material = bark
    for index in 12:
        positions.append(Vector3(-11.0 + index * 2.0, 2.6, -3.8))
        scales.append(Vector3.ONE * (0.85 + (index % 3) * 0.08))
    group_mesh("Trees", trunk, positions, scales)
    var canopy := SphereMesh.new()
    canopy.radius = 1.5
    canopy.height = 2.7
    canopy.radial_segments = 8
    canopy.rings = 4
    canopy.material = leaves
    positions.clear()
    scales.clear()
    for index in 24:
        positions.append(Vector3(-11.0 + (index / 2) * 2.0 + (index % 2) * 0.7, 5.3 + (index % 3) * 0.55, -3.65))
        scales.append(Vector3(1.0, 1.0 + (index % 3) * 0.1, 0.65))
    group_mesh("Canopies", canopy, positions, scales)
    var rock := SphereMesh.new()
    rock.radius = 0.6
    rock.height = 0.9
    rock.radial_segments = 6
    rock.rings = 3
    rock.material = stone
    positions.clear()
    scales.clear()
    for index in 12:
        positions.append(Vector3(-8.3 + index * 1.5, 0.75, -1.5))
        scales.append(Vector3(0.6 + (index % 3) * 0.2, 0.5, 0.7))
    group_mesh("Rocks", rock, positions, scales)
    var plant := CylinderMesh.new()
    plant.top_radius = 0.0
    plant.bottom_radius = 0.19
    plant.height = 0.75
    plant.radial_segments = 4
    plant.rings = 1
    plant.material = fern
    positions.clear()
    scales.clear()
    for index in 30:
        positions.append(Vector3(-8.6 + index * 0.59, 0.85, -1.55))
        scales.append(Vector3(1, 0.65 + (index % 4) * 0.14, 1))
    group_mesh("Plants", plant, positions, scales)
    var shard := CylinderMesh.new()
    shard.top_radius = 0.0
    shard.bottom_radius = 0.3
    shard.height = 1.2
    shard.radial_segments = 5
    shard.rings = 1
    shard.material = crystal
    positions.clear()
    scales.clear()
    for index in 10:
        positions.append(Vector3(-8.0 + index * 1.75, 1.0, -1.75))
        scales.append(Vector3(0.65, 0.65 + (index % 3) * 0.1, 0.65))
    group_mesh("Crystals", shard, positions, scales)
    var motes := CPUParticles3D.new()
    motes.name = "MagicMotes"
    motes.amount = 18
    motes.lifetime = 5.0
    motes.preprocess = 5.0
    motes.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
    motes.emission_box_extents = Vector3(8.0, 2.3, 1.0)
    motes.position = Vector3(0, 2.8, -1.0)
    motes.direction = Vector3.UP
    motes.gravity = Vector3.ZERO
    motes.initial_velocity_min = 0.1
    motes.initial_velocity_max = 0.25
    var mote := SphereMesh.new()
    mote.radius = 0.035
    mote.height = 0.07
    mote.radial_segments = 4
    mote.rings = 2
    mote.material = material(Color(0.42, 0.8, 0.64), true)
    motes.mesh = mote
    add_child(motes)
    var magic_light := OmniLight3D.new()
    magic_light.name = "MagicLight"
    magic_light.position = Vector3(0, 4, 1)
    magic_light.light_color = Color(0.45, 0.65, 1.0)
    magic_light.light_energy = 0.4
    magic_light.omni_range = 7.0
    magic_light.shadow_enabled = false
    add_child(magic_light)
    for side in [-1, 1]:
        var mushroom := Node3D.new()
        mushroom.set_script(preload("res://scripts/mushroom.gd"))
        mushroom.name = "MushroomLeft" if side < 0 else "MushroomRight"
        mushroom.position = Vector3(side * 9.8, -0.9, 0)
        add_child(mushroom)
