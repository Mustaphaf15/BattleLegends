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
    arena.get_node("Bot").ai_enabled = false
    root.add_child(arena)
    var frost = arena.get_node("Frost")
    var visual = frost.get_node("FrostVisual")
    check(not frost.get_node("Body").visible, "Frost placeholder must be hidden")
    check(arena.get_node("Bot/BotVisual") is Node3D, "Distinct animated bot model must be available")
    check(visual.find_children("*", "MeshInstance3D", true, false).size() >= 25, "Frost needs original humanoid armor and crystal geometry")
    check(visual.get_node("Rig/ChestCrystal") is MeshInstance3D, "Frost needs visible ice chest crystal")
    check(visual.get_node("Rig/ArmR/ShoulderSpike") is MeshInstance3D, "Frost needs crystal armor silhouette")
    var animations: AnimationPlayer = visual.get_node("AnimationPlayer")
    for title in ["Idle", "Run", "Jump", "Fall", "Attack", "Block", "Parry", "Hit", "KO"]:
        check(animations.has_animation(title), "Missing Frost animation " + title)
        var animation := animations.get_animation(title)
        check(animation.get_track_count() >= 6, "Every pose must explicitly animate and reset limbs")
    for frame in range(90):
        await physics_frame
    check(frost.animation_state == "Idle", "Landed Frost must enter Idle")
    frost.move_input = 1.0
    var start_x: float = frost.position.x
    for frame in range(10):
        await physics_frame
    check(frost.position.x > start_x + 0.5 and frost.animation_state == "Run", "Movement must animate Run while moving physically")
    frost.move_input = 0.0
    # Jump in a clear lane, away from the spring mushrooms at the arena edges.
    frost.position = Vector3(-3.5, 0.6, 0.0)
    frost.velocity = Vector3.ZERO
    for frame in range(8):
        await physics_frame
    frost.jump_requested = true
    for frame in range(4):
        await physics_frame
    check(frost.velocity.y > 0 and frost.animation_state == "Jump", "Physical ascent must animate Jump")
    for frame in range(28):
        await physics_frame
    check(frost.velocity.y < 0 and frost.animation_state == "Fall", "Physical descent must animate Fall")
    for frame in range(90):
        await physics_frame
    check(frost.animation_state == "Idle", "Landing must return to Idle")
    # Temporary visual attack must be callable from UI and keyboard with baseline distance-based damage.
    arena.get_node("Interface/Attack").pressed.emit()
    for frame in range(2):
        await physics_frame
    check(frost.animation_state == "Attack", "Touch attack Button must trigger Attack")
    var before_restart: float = frost.action_time
    frost.request_attack()
    check(is_equal_approx(before_restart, frost.action_time), "Repeated attacks must not restart the active animation")
    animations.advance(0.16)
    check(absf(visual.get_node("Rig/ArmR").rotation.z) > 0.3, "Attack animation must visibly rotate the striking arm")
    for frame in range(30):
        await physics_frame
    check(frost.animation_state == "Idle", "Attack completion must return to locomotion")
    for title in ["Block", "Parry", "Hit", "KO"]:
        frost.request_pose(title, 0.5)
        for frame in range(2):
            await physics_frame
        check(frost.animation_state == title and visual.state == title, title + " must select the matching animation")
        animations.advance(0.2)
        check(animations.current_animation == title, title + " must be played by AnimationPlayer")
    frost.request_pose("Hit", 0.01)
    for frame in range(3):
        await physics_frame
    check(frost.animation_state == "Idle", "Transient pose expiry must restore locomotion")
    frost.move_input = -1.0
    for frame in range(2):
        await physics_frame
    check(visual.scale.x < 0 and frost.get_node("CollisionShape3D").scale == Vector3.ONE, "Facing must mirror visual without mirroring physics")
    check(absf(frost.position.z) < 0.001, "Animated Frost must remain on combat plane")
    check(visual.get_node("IceEffect").get_child_count() == 5, "Ice effect must use a bounded five-shard budget")
    arena.free()
    print("Frost tests: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
    quit(0 if failures == 0 else 1)
