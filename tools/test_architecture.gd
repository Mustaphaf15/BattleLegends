extends SceneTree

var failures := 0

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error(description)

func _initialize() -> void:
    call_deferred("run_tests")

func run_tests() -> void:
    var packed = load("res://scenes/arena_3d.tscn")
    check(packed is PackedScene, "3D arena must be reusable")
    if packed == null:
        quit(1)
        return
    var arena = packed.instantiate()
    root.add_child(arena)
    check(arena is Node3D, "Main arena must be Node3D")
    var camera = arena.find_child("Camera3D", true, false)
    check(camera is Camera3D and camera.current, "3D side camera must be current")
    check(camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "Camera must use orthographic side projection")
    check(arena.find_child("WorldEnvironment", true, false) is WorldEnvironment, "3D world needs environment")
    check(arena.find_child("DirectionalLight3D", true, false) is DirectionalLight3D, "3D world needs sunlight")
    var frost = arena.find_child("Frost", true, false)
    var bot = arena.find_child("Bot", true, false)
    check(frost is CharacterBody3D and bot is CharacterBody3D, "Both fighters need physical character bodies")
    check(frost.find_children("*", "CollisionShape3D", true, false).size() > 0, "Fighter needs physical collider")
    check(arena.find_children("*", "StaticBody3D", true, false).size() >= 1, "Arena needs physical platforms")
    for frame in range(120):
        await physics_frame
    check(absf(frost.position.z) < 0.001 and absf(bot.position.z) < 0.001, "Fighters must stay on combat plane")
    check(frost.is_on_floor() and bot.is_on_floor(), "Fighters must land on physical arena")
    var initial_x: float = frost.position.x
    frost.move_input = 1.0
    for frame in range(12):
        await physics_frame
    check(frost.position.x > initial_x + 0.5, "Fighter must move horizontally")
    frost.move_input = 0.0
    var initial_y: float = frost.position.y
    frost.jump_requested = true
    for frame in range(6):
        await physics_frame
    check(frost.position.y > initial_y + 0.2, "Fighter must jump using physics")
    check(absf(frost.position.z) < 0.001, "Jump must stay on combat plane")
    arena.free()
    print("3D architecture tests: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
    quit(0 if failures == 0 else 1)
