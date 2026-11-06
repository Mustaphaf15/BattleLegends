extends SceneTree

var failures := 0

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error(description)

func _initialize() -> void:
    call_deferred("run_tests")

func run_tests() -> void:
    var arena = load("res://scenes/arena_3d.tscn").instantiate()
    root.add_child(arena)
    var forest = arena.get_node("Forest")
    var frost = arena.get_node("Frost")
    var bot = arena.get_node("Bot")
    bot.ai_enabled = false
    bot.position.x = 4.0
    frost.opponent = null
    for group_name in ["Trees", "Canopies", "Rocks", "Plants", "Crystals"]:
        check(forest.get_node(group_name) is MultiMeshInstance3D, "Forest needs batched original " + group_name)
    check(forest.instance_budget == 88 and forest.triangle_budget < 7000, "Decorative mesh budget must stay bounded")
    check(forest.material_count <= 6, "Forest materials must be shared and bounded")
    check(forest.get_node("MagicMotes").amount == 18, "Magical particles must stay bounded")
    check(not forest.get_node("MagicLight").shadow_enabled, "Extra magical light must avoid costly shadows")
    for platform_name in ["MainPlatform", "UpperPlatform", "LeftPlatform", "RightPlatform"]:
        check(arena.get_node(platform_name) is StaticBody3D, "Platform collision must remain: " + platform_name)
    # Player can now walk under low platforms instead of hitting their side walls.
    for frame in range(15):
        await physics_frame
    frost.move_input = -1.0
    for frame in range(25):
        await physics_frame
    frost.move_input = 0.0
    check(frost.position.x < -6.0, "Side platforms must not block ground-level movement")
    # Jump through the underside and land on the same reachable side platform.
    frost.position = Vector3(-5.5, 0.53, 0)
    frost.velocity = Vector3.ZERO
    for frame in range(5):
        await physics_frame
    frost.jump_requested = true
    var passed_top := false
    for frame in range(65):
        await physics_frame
        if frost.position.y > 2.1:
            passed_top = true
    check(passed_top and frost.is_on_floor() and absf(frost.position.y - 2.0) < 0.12, "One-way platform must allow ascent and support landing")
    var mushroom = forest.get_node("MushroomLeft")
    check(mushroom.has_node("SpringSurface") and mushroom.has_node("BounceTrigger"), "Mushroom needs physical cap and trigger")
    frost.position = Vector3(-9.8, 3.8, 0)
    frost.velocity = Vector3(0, -2, 0)
    var count_before: int = mushroom.bounce_count
    var bounced_up := false
    for frame in range(60):
        await physics_frame
        if mushroom.bounce_count > count_before and frost.velocity.y > 10.0:
            bounced_up = true
    check(bounced_up and mushroom.bounce_count == count_before + 1, "Real descending fighter must bounce once on mushroom")
    # Explicit reentry attempts during cooldown must not create repeated impulses.
    frost.velocity.y = -1.0
    mushroom._body_exited(frost)
    mushroom.last_bounce[frost.get_instance_id()] = mushroom.elapsed
    check(not mushroom.try_bounce(frost), "Reentry during cooldown must not bounce")
    # Reproduce cached floor contact before a fresh jump's next move_and_slide.
    frost.set_physics_process(false)
    frost.position = Vector3(-9.8, -0.21, 0)
    frost.velocity = Vector3(0, -0.2, 0)
    frost.move_and_slide()
    check(frost.is_on_floor(), "Regression fixture must retain actual mushroom cap floor contact")
    mushroom._body_exited(frost)
    mushroom.last_bounce.clear()
    frost.velocity.y = 3.0
    check(not mushroom.try_bounce(frost) and is_equal_approx(frost.velocity.y, 3.0), "Cached floor state must never turn an ascending jump into a spring bounce")
    # Ascending contact never steals or amplifies a normal jump.
    frost.set_physics_process(false)
    frost.position = Vector3(-9.8, 4.0, 0)
    for frame in range(50):
        await physics_frame
    frost.position = Vector3(-9.8, -0.1, 0)
    frost.velocity.y = 3.0
    check(not mushroom.try_bounce(frost), "Ascending fighter must not bounce")
    # A later real fall exits and reenters naturally and can bounce a second time.
    frost.position = Vector3(-9.8, 4.0, 0)
    frost.velocity = Vector3.ZERO
    frost.set_physics_process(true)
    var count_second: int = mushroom.bounce_count
    for frame in range(65):
        await physics_frame
    check(mushroom.bounce_count == count_second + 1, "New descending entry after cooldown must bounce again")
    print("Forest measured decorative triangles: ", forest.triangle_budget)
    arena.free()
    print("Forest tests: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
    quit(0 if failures == 0 else 1)
