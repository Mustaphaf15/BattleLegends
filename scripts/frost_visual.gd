extends Node3D

## Original procedural ice sentinel. All geometry and poses are authored here.
const ANIMATIONS := ["Idle", "Run", "Jump", "Fall", "Attack", "Block", "Parry", "Hit", "KO"]
var animation_player: AnimationPlayer
var ice_effect: Node3D
var state := ""
var effect_clock := 0.0

func _ready() -> void:
    var armor := material(Color("287dba"), 0.55)
    var dark := material(Color("123e69"), 0.7)
    var ice := material(Color("a2f2ff"), 0.22, true)
    var pale := material(Color("d0eaff"), 0.5)
    var rig := joint("Rig", self, Vector3.ZERO)
    box("Torso", rig, Vector3(0, 1.25, 0), Vector3(0.76, 0.65, 0.42), armor)
    box("Waist", rig, Vector3(0, 0.86, 0), Vector3(0.48, 0.19, 0.35), dark)
    box("ChestCrystal", rig, Vector3(0, 1.28, 0.25), Vector3(0.19, 0.28, 0.12), ice).rotation.z = PI / 4
    box("Head", rig, Vector3(0, 1.82, 0), Vector3(0.45, 0.44, 0.38), pale)
    box("Helmet", rig, Vector3(0, 2.03, -0.025), Vector3(0.55, 0.16, 0.44), armor)
    box("Visor", rig, Vector3(0, 1.86, 0.2), Vector3(0.39, 0.10, 0.035), dark)
    box("Eyes", rig, Vector3(0, 1.87, 0.225), Vector3(0.30, 0.035, 0.025), ice)
    for side in [-1, 1]:
        var suffix := "L" if side < 0 else "R"
        var arm := joint("Arm" + suffix, rig, Vector3(side * 0.48, 1.48, 0))
        box("Shoulder", arm, Vector3.ZERO, Vector3(0.36, 0.31, 0.46), armor)
        box("Gauntlet", arm, Vector3(0, -0.36, 0), Vector3(0.24, 0.53, 0.3), dark)
        box("Hand", arm, Vector3(0, -0.65, 0), Vector3(0.26, 0.22, 0.3), ice)
        crystal("ShoulderSpike", arm, Vector3(side * 0.06, 0.25, 0), 0.16, 0.52, ice).rotation.z = -side * 0.4
        var leg := joint("Leg" + suffix, rig, Vector3(side * 0.23, 0.81, 0))
        box("Greave", leg, Vector3(0, -0.32, 0), Vector3(0.32, 0.64, 0.36), armor)
        box("Boot", leg, Vector3(0.04, -0.69, 0.06), Vector3(0.40, 0.22, 0.48), dark)
    for index in range(3):
        crystal("Crown" + str(index), rig, Vector3((index - 1) * 0.17, 2.16, -0.025), 0.09, 0.40 if index == 1 else 0.27, ice)
    # Faceted back crystals make Frost recognizable in silhouette.
    for index in range(3):
        crystal("BackCrystal" + str(index), rig, Vector3((index - 1) * 0.25, 1.52, -0.3), 0.11, 0.5, ice).rotation.x = -0.55
    ice_effect = joint("IceEffect", self, Vector3(0, 1.15, 0))
    for index in range(5):
        var angle := TAU * index / 5.0
        var shard := crystal("Shard" + str(index), ice_effect, Vector3(cos(angle) * 0.9, sin(angle) * 0.6, 0.25), 0.045, 0.20, ice)
        shard.rotation.z = -angle
        shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    _build_animations()
    play_state("Idle")

func material(color: Color, roughness: float, glowing := false) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = color
    result.roughness = roughness
    result.metallic = 0.18
    result.emission_enabled = glowing
    result.emission = color * 0.35 if glowing else Color.BLACK
    return result

func joint(title: String, parent: Node3D, location: Vector3) -> Node3D:
    var result := Node3D.new()
    result.name = title
    result.position = location
    parent.add_child(result)
    return result

func box(title: String, parent: Node3D, location: Vector3, size: Vector3, surface: Material) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    return mesh_part(title, parent, location, mesh, surface)

func crystal(title: String, parent: Node3D, location: Vector3, radius: float, height: float, surface: Material) -> MeshInstance3D:
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 5
    mesh.rings = 1
    return mesh_part(title, parent, location, mesh, surface)

func mesh_part(title: String, parent: Node3D, location: Vector3, mesh: Mesh, surface: Material) -> MeshInstance3D:
    var result := MeshInstance3D.new()
    result.name = title
    result.mesh = mesh
    result.material_override = surface
    result.position = location
    parent.add_child(result)
    return result

func _build_animations() -> void:
    animation_player = AnimationPlayer.new()
    animation_player.name = "AnimationPlayer"
    add_child(animation_player)
    var library := AnimationLibrary.new()
    for title in ANIMATIONS:
        var animation := Animation.new()
        animation.length = 0.65 if title == "Run" else 1.2
        if title == "Attack" or title == "Parry" or title == "Hit":
            animation.length = 0.4
        if title == "Idle" or title == "Run" or title == "Block":
            animation.loop_mode = Animation.LOOP_LINEAR
        var arm_l := [0.06, -0.06, 0.06]
        var arm_r := [-0.06, 0.06, -0.06]
        var leg_l := [0.0, 0.0, 0.0]
        var leg_r := [0.0, 0.0, 0.0]
        var tilt := [0.0, 0.0, 0.0]
        var lift := [0.0, 0.035, 0.0]
        match title:
            "Run":
                arm_l = [-0.75, 0.75, -0.75]
                arm_r = [0.75, -0.75, 0.75]
                leg_l = [0.6, -0.6, 0.6]
                leg_r = [-0.6, 0.6, -0.6]
                tilt = [-0.08, -0.08, -0.08]
                lift = [0.0, 0.07, 0.0]
            "Jump":
                arm_l = [0.6, 0.7, 0.6]
                arm_r = [-0.6, -0.7, -0.6]
                leg_l = [0.2, 0.3, 0.2]
                leg_r = [-0.3, -0.4, -0.3]
            "Fall":
                arm_l = [0.95, 1.1, 0.95]
                arm_r = [-0.95, -1.1, -0.95]
                leg_l = [0.1, 0.15, 0.1]
                leg_r = [-0.1, -0.15, -0.1]
            "Attack":
                arm_r = [-0.2, 1.7, -0.2]
                tilt = [0.05, -0.2, 0.0]
            "Block":
                arm_l = [0.2, 0.25, 0.2]
                arm_r = [1.3, 1.4, 1.3]
                tilt = [0.12, 0.12, 0.12]
            "Parry":
                arm_r = [0.5, 2.3, 1.2]
                arm_l = [-0.2, -0.4, -0.2]
            "Hit":
                tilt = [0.0, 0.38, 0.0]
                arm_r = [-0.3, -0.7, -0.1]
            "KO":
                tilt = [0.0, -1.45, -1.45]
                lift = [0.0, -0.1, -0.1]
        _rotation_track(animation, "Rig/ArmL:rotation", arm_l)
        _rotation_track(animation, "Rig/ArmR:rotation", arm_r)
        _rotation_track(animation, "Rig/LegL:rotation", leg_l)
        _rotation_track(animation, "Rig/LegR:rotation", leg_r)
        _rotation_track(animation, "Rig:rotation", tilt)
        var lift_track := animation.add_track(Animation.TYPE_VALUE)
        animation.track_set_path(lift_track, NodePath("Rig:position"))
        for index in range(3):
            animation.track_insert_key(lift_track, animation.length * index / 2.0, Vector3(0, lift[index], 0))
        library.add_animation(title, animation)
    animation_player.add_animation_library("", library)

func _rotation_track(animation: Animation, path: String, values: Array) -> void:
    var track := animation.add_track(Animation.TYPE_VALUE)
    animation.track_set_path(track, NodePath(path))
    for index in range(3):
        animation.track_insert_key(track, animation.length * index / 2.0, Vector3(0, 0, values[index]))

func play_state(next_state: String) -> void:
    if next_state == state or not ANIMATIONS.has(next_state):
        return
    state = next_state
    animation_player.play(next_state, 0.08)

func _process(delta: float) -> void:
    effect_clock += delta
    ice_effect.rotation.z = effect_clock * (3.0 if state == "Attack" else 0.45)
    ice_effect.scale = Vector3.ONE * (1.3 if state == "Parry" or state == "Attack" else 0.72)
