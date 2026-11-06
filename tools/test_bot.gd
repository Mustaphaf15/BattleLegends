extends SceneTree

var failures := 0
var attacks := 0

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error(description)

func _initialize() -> void:
    call_deferred("run_tests")

func run_tests() -> void:
    var arena = load("res://scenes/arena_3d.tscn").instantiate()
    root.add_child(arena)
    var frost = arena.get_node("Frost")
    var bot = arena.get_node("Bot")
    var visual = bot.get_node("BotVisual")
    check(not bot.get_node("Body").visible, "Bot placeholder must be replaced")
    check(visual.has_node("Rig/Horn1") and visual.has_node("Rig/ArmR/HammerHead"), "Cinder needs its distinct original horned hammer silhouette")
    check(not visual.has_node("Rig/Crown0") and not visual.get_node("IceEffect").visible, "Bot must not carry Frost's crown or ice effects")
    var animation_player: AnimationPlayer = visual.get_node("AnimationPlayer")
    for title in ["Idle", "Run", "Jump", "Fall", "Attack", "Block", "Parry", "Hit", "KO"]:
        check(animation_player.has_animation(title), "Bot needs shared combat animation " + title)
    bot.attack_started.connect(func(_fighter) -> void: attacks += 1)
    var initial_distance: float = absf(bot.position.x - frost.position.x)
    for frame in range(45):
        await physics_frame
    check(absf(bot.position.x - frost.position.x) < initial_distance - 1.0, "Enabled bot must pursue Frost")
    check(bot.animation_state == "Run", "Pursuit must animate the bot")
    bot.ai_enabled = false
    frost.position = Vector3(-8.0, 0.6, 0)
    bot.position = Vector3(-6.65, 0.6, 0)
    frost.velocity = Vector3.ZERO
    bot.velocity = Vector3.ZERO
    for frame in range(15):
        await physics_frame
    bot.facing = -1.0
    var initial_health: int = frost.health
    bot.request_attack()
    for frame in range(20):
        await physics_frame
    check(frost.health == initial_health - bot.attack_damage, "One bot swing must deliver exactly one delayed hit")
    var first_attacks: int = attacks
    bot.request_attack()
    check(attacks == first_attacks, "Attack cooldown must reject rapid repeat requests")
    # Vertical separation must exclude hits, unlike the 2D baseline's x-only range.
    frost.position.y = bot.position.y + 3.0
    var health_above: int = frost.health
    bot._resolve_attack()
    check(frost.health == health_above, "Bot must not damage a vertically distant target")
    bot.receive_hit(1, 0.0)
    var health_bot: int = bot.health
    check(health_bot == 99 and bot.stun_time > 0.0, "Damage must enter a finite hitstun")
    bot.ai_enabled = true
    var before_stun_attacks: int = attacks
    var before_stun_x: float = bot.position.x
    for frame in range(8):
        bot.request_attack()
        await physics_frame
    check(attacks == before_stun_attacks, "Stunned bot must not start attacks")
    check(absf(bot.position.x - before_stun_x) < 0.01 and bot.animation_state == "Hit", "Hitstun must suspend pursuit and animate Hit")
    # Isolate a reachable vertical pursuit scenario beneath a side-platform edge.
    arena.restart_match()
    frost.position = Vector3(5.5, 2.02, 0)
    bot.position = Vector3(7.9, 0.52, 0)
    bot.velocity = Vector3.ZERO
    var saw_jump := false
    for frame in range(100):
        await physics_frame
        if bot.velocity.y > 1.0:
            saw_jump = true
    check(saw_jump, "Bot must jump when pursuing a reachable elevated opponent")
    arena.restart_match()
    frost.position = Vector3(0, 3.3, 0)
    bot.position = Vector3(7.9, 0.52, 0)
    bot.velocity = Vector3.ZERO
    var reached_upper_level := false
    for frame in range(280):
        await physics_frame
        if bot.position.y > 3.0:
            reached_upper_level = true
    check(reached_upper_level, "Bot must use a side-platform step to pursue the highest platform")
    # Complete a deterministic full-health fight through real attack requests.
    arena.restart_match()
    bot.ai_enabled = false
    for swing in range(9):
        frost.position = Vector3(-8.0, 0.52, 0)
        bot.position = Vector3(-6.6, 0.52, 0)
        frost.velocity = Vector3.ZERO
        bot.velocity = Vector3.ZERO
        frost.facing = 1.0
        frost.request_attack()
        for frame in range(42):
            await physics_frame
    check(arena.match_finished and bot.health == 0, "Frost must finish a full baseline fight")
    check(arena.get_node("Interface/MatchMessage").text == "VICTOIRE !" and arena.get_node("Interface/Replay").visible, "Victory must expose replay")
    check(bot.animation_state == "KO", "Defeated bot must remain in KO")
    arena.get_node("Interface/Replay").pressed.emit()
    check(not arena.match_finished and frost.health == 100 and bot.health == 100, "Replay Button must reset round health and outcome")
    check(not bot.defeated_state and not bot.attack_pending and bot.stun_time == 0.0, "Replay must clear all transient combat states")
    # Autonomous bot can close the round against a vulnerable player.
    bot.ai_enabled = true
    frost.health = 9
    frost.position = Vector3(-8.0, 0.52, 0)
    bot.position = Vector3(-6.65, 0.52, 0)
    for frame in range(80):
        await physics_frame
    check(arena.match_finished and frost.health == 0, "Bot must autonomously defeat Frost")
    check(arena.get_node("Interface/MatchMessage").text == "DÉFAITE !", "Player KO must display defeat")
    var attacks_at_end: int = attacks
    for frame in range(70):
        await physics_frame
    check(attacks == attacks_at_end, "Finished round must prevent further automatic attacks")
    arena.free()
    print("Bot tests: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
    quit(0 if failures == 0 else 1)
