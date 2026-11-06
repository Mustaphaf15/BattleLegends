extends "res://scripts/frost_visual.gd"

## Cinder Warden: original copper/charcoal construct, horned helmet and forge hammer.
## Shares the articulated skeleton and animation vocabulary with Frost.
func _ready() -> void:
    super._ready()
    var copper := material(Color("b65e30"), 0.7)
    var charcoal := material(Color("252734"), 0.9)
    var fire := material(Color("ff9e46"), 0.45, true)
    for part in find_children("*", "MeshInstance3D", true, false):
        part.material_override = copper if part.name in ["Torso", "Helmet", "Shoulder", "Greave"] else charcoal
    get_node("Rig/ChestCrystal").material_override = fire
    get_node("Rig/ChestCrystal").rotation.z = 0.0
    get_node("Rig/ChestCrystal").scale = Vector3(1.5, 0.6, 1.0)
    get_node("Rig/Eyes").material_override = fire
    get_node("Rig/Helmet").scale = Vector3(1.35, 1.4, 1.2)
    for index in range(3):
        get_node("Rig/Crown" + str(index)).free()
        get_node("Rig/BackCrystal" + str(index)).free()
    for side in ["L", "R"]:
        get_node("Rig/Arm" + side + "/ShoulderSpike").free()
        get_node("Rig/Arm" + side + "/Shoulder").scale = Vector3(1.25, 1.15, 1.25)
    var rig := get_node("Rig")
    for side in [-1, 1]:
        var horn := crystal("Horn" + str(side), rig, Vector3(side * 0.35, 2.10, 0), 0.11, 0.55, copper)
        horn.rotation.z = -side * 0.8
    var hand := get_node("Rig/ArmR")
    box("HammerHandle", hand, Vector3(0.10, -0.85, 0.03), Vector3(0.12, 0.8, 0.14), charcoal)
    box("HammerHead", hand, Vector3(0.10, -1.16, 0.03), Vector3(0.60, 0.32, 0.39), copper)
    box("HammerCore", hand, Vector3(0.10, -1.16, 0.24), Vector3(0.23, 0.13, 0.035), fire)
    ice_effect.hide()
