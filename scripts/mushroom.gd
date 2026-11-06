extends Node3D

## Original spring mushroom. Each entry bounces once, with a bounded cooldown.
@export var bounce_speed := 14.5
@export var cooldown_seconds := 0.8
var bounce_count := 0
var occupants := {}
var last_bounce := {}
var elapsed := 0.0
var trigger: Area3D

func _ready() -> void:
    var stem_material := StandardMaterial3D.new()
    stem_material.albedo_color = Color(0.66, 0.8, 0.65)
    var cap_material := StandardMaterial3D.new()
    cap_material.albedo_color = Color(0.7, 0.14, 0.62)
    cap_material.emission_enabled = true
    cap_material.emission = Color(0.2, 0.03, 0.17)
    var stem := CylinderMesh.new()
    stem.top_radius = 0.19
    stem.bottom_radius = 0.25
    stem.height = 0.45
    stem.radial_segments = 8
    stem.material = stem_material
    var stalk := MeshInstance3D.new()
    stalk.mesh = stem
    stalk.position.y = 0.225
    add_child(stalk)
    var cap := SphereMesh.new()
    cap.radius = 0.7
    cap.height = 0.5
    cap.radial_segments = 10
    cap.rings = 4
    cap.material = cap_material
    var crown := MeshInstance3D.new()
    crown.name = "Cap"
    crown.mesh = cap
    crown.position.y = 0.48
    add_child(crown)
    var solid := StaticBody3D.new()
    solid.name = "SpringSurface"
    solid.collision_layer = 1
    solid.collision_mask = 2
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(1.2, 0.18, 1.0)
    shape.shape = box
    shape.position.y = 0.6
    solid.add_child(shape)
    add_child(solid)
    trigger = Area3D.new()
    trigger.name = "BounceTrigger"
    trigger.collision_layer = 0
    trigger.collision_mask = 2
    var detection := CollisionShape3D.new()
    var detection_box := BoxShape3D.new()
    detection_box.size = Vector3(1.1, 0.2, 0.9)
    detection.shape = detection_box
    detection.position.y = 0.76
    trigger.add_child(detection)
    add_child(trigger)
    trigger.body_exited.connect(_body_exited)

func _body_exited(body: Node3D) -> void:
    occupants.erase(body.get_instance_id())

func try_bounce(body: CharacterBody3D) -> bool:
    var id := body.get_instance_id()
    if occupants.has(id) or elapsed - float(last_bounce.get(id, -100.0)) < cooldown_seconds:
        return false
    # Area overlap notifications can arrive one physics tick after solid contact.
    # Accept the actual cap landing as well as a still-descending body.
    if body.velocity.y > 0.1:
        return false
    var on_cap := body.is_on_floor() and absf(body.global_position.y - (global_position.y + 0.69)) < 0.1
    if (body.velocity.y >= -0.1 and not on_cap) or body.global_position.y < global_position.y + 0.5:
        return false
    if body.get("defeated_state") == true or body.get("match_active") == false:
        return false
    body.velocity.y = bounce_speed
    occupants[id] = true
    last_bounce[id] = elapsed
    bounce_count += 1
    return true

func _physics_process(delta: float) -> void:
    elapsed += delta
    for body in trigger.get_overlapping_bodies():
        if body is CharacterBody3D:
            try_bounce(body)
    # Entries expire so repeated scene changes cannot grow the dictionary.
    for id in last_bounce.keys():
        if elapsed - float(last_bounce[id]) > 10.0:
            last_bounce.erase(id)
