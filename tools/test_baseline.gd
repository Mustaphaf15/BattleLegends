extends SceneTree

var failures := 0

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error(description)

func _initialize() -> void:
    call_deferred("run_tests")

func run_tests() -> void:
    var arena = load("res://scenes/arena.tscn").instantiate()
    root.add_child(arena)
    arena.set_physics_process(false)
    arena.vy = -100.0
    arena.hp = 0
    arena.enemy_hp = 0
    arena.parry = 0.3
    arena.stun = 1.5
    arena.combo = 3
    arena.combo_time = 1.0
    arena.attack_cd = 0.1
    arena.bot_cd = 0.9
    arena.finished = true
    arena.held[7] = Vector2(1170, 535)
    arena.arrows = true
    arena.reset_match()
    check(arena.hp == 100 and arena.enemy_hp == 100, "Replay must restore health")
    check(arena.p == Vector2(300, 570) and arena.enemy == Vector2(950, 570), "Replay must restore positions")
    check(arena.vy == 0 and arena.parry == 0 and arena.stun == 0, "Replay must reset movement and statuses")
    check(arena.combo == 0 and arena.combo_time == 0, "Replay must reset combo")
    check(arena.attack_cd == 0 and arena.bot_cd == 0, "Replay must reset cooldowns")
    check(not arena.finished and arena.held.is_empty(), "Replay must clear finished and touches")
    check(arena.arrows, "Replay must preserve control preference")
    arena.held[7] = Vector2(1170, 535)
    arena.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    check(arena.held.is_empty(), "Focus loss must release touch controls")
    arena.free()
    var legend = load("res://scenes/legend_unlock.tscn").instantiate()
    root.add_child(legend)
    legend._finish_unlock()
    legend._process(0.016)
    check(legend.completed, "Legend must record completion")
    check(legend.message.text == "LEGEND UNLOCKED!", "Legend final message must persist")
    check(legend.get_node("ReturnButton").visible, "Legend must offer return navigation")
    current_scene = legend
    legend.get_node("ReturnButton").pressed.emit()
    await process_frame
    await process_frame
    check(current_scene != null and current_scene.scene_file_path == "res://scenes/arena.tscn", "Legend return must load arena")
    if current_scene != null:
        current_scene.free()
    print("Baseline regression tests: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
    quit(0 if failures == 0 else 1)
