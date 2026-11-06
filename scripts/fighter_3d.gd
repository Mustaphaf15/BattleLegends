extends CharacterBody3D

signal attack_started(fighter)
signal defeated(fighter)

## Physical fighters share the X/Y combat plane and animation API.
@export var player_controlled := true
@export var ai_enabled := true
@export var move_speed := 7.0
@export var jump_speed := 11.0
@export var gravity := 26.0
@export var spawn_position := Vector3(-4, 0.6, 0)
@export var attack_interval := 0.65
@export var attack_damage := 12
var move_input := 0.0
var jump_requested := false
var frost_visual: Node3D
var animation_state := "Idle"
var action_state := ""
var action_time := 0.0
var facing := 1.0
var opponent: CharacterBody3D
var health := 100
var defeated_state := false
var match_active := true
var stun_time := 0.0
var attack_cooldown := 0.0
var attack_windup := 0.0
var attack_pending := false
var ai_jump_cooldown := 0.0
var ai_takeoff_x := INF
var ai_step_platform: StaticBody3D
var recoil := 0.0

func _ready() -> void:
    $Body.hide()
    frost_visual = Node3D.new()
    frost_visual.set_script(preload("res://scripts/frost_visual.gd") if player_controlled else preload("res://scripts/bot_visual.gd"))
    frost_visual.name = "FrostVisual" if player_controlled else "BotVisual"
    add_child(frost_visual)
    if not player_controlled:
        facing = -1.0

func request_attack() -> void:
    if not match_active or defeated_state or stun_time > 0.0 or action_time > 0.0 or attack_cooldown > 0.0:
        return
    request_pose("Attack", 0.4)
    attack_cooldown = attack_interval
    attack_windup = 0.14
    attack_pending = true
    attack_started.emit(self)

func request_pose(pose: String, duration: float) -> void:
    if pose in ["Attack", "Block", "Parry", "Hit", "KO"]:
        action_state = pose
        action_time = maxf(duration, 0.01)

func receive_hit(damage: int, direction: float) -> void:
    if not match_active or defeated_state:
        return
    health = maxi(health - maxi(damage, 0), 0)
    attack_pending = false
    recoil = direction * 3.0
    if health == 0:
        defeated_state = true
        request_pose("KO", 10.0)
        defeated.emit(self)
    else:
        stun_time = 0.35
        request_pose("Hit", stun_time)

func _resolve_attack() -> void:
    if not is_instance_valid(opponent) or opponent.defeated_state:
        return
    var gap: Vector3 = opponent.global_position - global_position
    # Baseline distance check; formal hitbox/hurtbox rules arrive in task07.
    if absf(gap.x) <= 1.7 and absf(gap.y) <= 0.9 and gap.x * facing >= -0.15:
        opponent.receive_hit(attack_damage, facing)

func reset_fighter() -> void:
    global_position = spawn_position
    velocity = Vector3.ZERO
    move_input = 0.0
    jump_requested = false
    health = 100
    defeated_state = false
    match_active = true
    stun_time = 0.0
    attack_cooldown = 0.0
    attack_windup = 0.0
    attack_pending = false
    ai_jump_cooldown = 0.0
    ai_takeoff_x = INF
    ai_step_platform = null
    recoil = 0.0
    action_state = ""
    action_time = 0.0
    facing = 1.0 if player_controlled else -1.0
    update_visual(0.0)

func update_visual(delta: float) -> void:
    action_time = maxf(action_time - delta, 0.0)
    if action_time <= 0.0:
        action_state = ""
    if defeated_state:
        animation_state = "KO"
    elif action_state != "":
        animation_state = action_state
    elif not is_on_floor():
        animation_state = "Jump" if velocity.y > 0.0 else "Fall"
    elif absf(velocity.x) > 0.1:
        animation_state = "Run"
    else:
        animation_state = "Idle"
    if absf(velocity.x) > 0.1 and stun_time <= 0.0:
        facing = signf(velocity.x)
    if is_instance_valid(frost_visual):
        frost_visual.scale.x = facing
        frost_visual.play_state(animation_state)

func _ai_axis() -> float:
    if not ai_enabled or not is_instance_valid(opponent) or opponent.defeated_state:
        return 0.0
    var goal: Vector3 = opponent.global_position
    # Use a reachable side platform when the target is above one-jump height.
    if is_instance_valid(ai_step_platform):
        var step_top: float = ai_step_platform.global_position.y + ai_step_platform.global_transform.basis.y.length() * 0.5
        if (is_on_floor() and global_position.y >= step_top - 0.1) or goal.y <= global_position.y + 0.5:
            ai_step_platform = null
        else:
            goal = Vector3(ai_step_platform.global_position.x, step_top, 0.0)
    if not is_instance_valid(ai_step_platform) and goal.y - global_position.y > jump_speed * jump_speed / (2.0 * gravity) - 0.1:
        var best_distance := INF
        for candidate in get_parent().get_children():
            if candidate is StaticBody3D:
                var top: float = candidate.global_position.y + candidate.global_transform.basis.y.length() * 0.5
                var rise: float = top - global_position.y
                if rise > 0.4 and rise < jump_speed * jump_speed / (2.0 * gravity) - 0.1:
                    var distance: float = absf(candidate.global_position.x - global_position.x)
                    if distance < best_distance:
                        best_distance = distance
                        ai_step_platform = candidate
                        goal = Vector3(candidate.global_position.x, top, 0.0)
    var gap: Vector3 = goal - global_position
    if absf(gap.x) > 0.05:
        facing = signf(gap.x)
    if is_on_floor() and gap.y > 0.6:
        if is_inf(ai_takeoff_x) and ai_jump_cooldown <= 0.0:
            # If a platform blocks a direct jump, run past its nearest edge first.
            var ray := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 2.05, 0), global_position + Vector3(0, 3.1, 0), 1)
            var ceiling := get_world_3d().direct_space_state.intersect_ray(ray)
            if not ceiling.is_empty():
                var platform = ceiling["collider"]
                if platform is StaticBody3D:
                    var half_width: float = absf(platform.global_transform.basis.x.length()) * 0.5
                    var side := -1.0 if global_position.x < platform.global_position.x else 1.0
                    ai_takeoff_x = platform.global_position.x + side * (half_width + 0.75)
        if not is_inf(ai_takeoff_x):
            if absf(global_position.x - ai_takeoff_x) > 0.12:
                return signf(ai_takeoff_x - global_position.x)
            ai_takeoff_x = INF
        if ai_jump_cooldown <= 0.0:
            jump_requested = true
            ai_jump_cooldown = 0.9
    var attack_gap: Vector3 = opponent.global_position - global_position
    if absf(attack_gap.x) <= 1.5 and absf(attack_gap.y) <= 0.9:
        request_attack()
        return 0.0
    return signf(gap.x) if absf(gap.x) > 0.4 else 0.0

func _physics_process(delta: float) -> void:
    attack_cooldown = maxf(attack_cooldown - delta, 0.0)
    stun_time = maxf(stun_time - delta, 0.0)
    ai_jump_cooldown = maxf(ai_jump_cooldown - delta, 0.0)
    if attack_pending:
        attack_windup = maxf(attack_windup - delta, 0.0)
        if attack_windup <= 0.0:
            attack_pending = false
            _resolve_attack()
    var axis := 0.0
    if match_active and not defeated_state and stun_time <= 0.0:
        if player_controlled:
            var keyboard_axis := float(int(Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_Q)))
            axis = keyboard_axis if not is_zero_approx(keyboard_axis) else move_input
        else:
            axis = _ai_axis()
        if jump_requested and is_on_floor():
            velocity.y = jump_speed
    jump_requested = false
    velocity.x = clampf(axis, -1.0, 1.0) * move_speed + recoil
    recoil = move_toward(recoil, 0.0, delta * 18.0)
    if not is_on_floor():
        velocity.y -= gravity * delta
    velocity.z = 0.0
    move_and_slide()
    global_position.z = 0.0
    # Temporary safety reset until the Smash match rules are introduced.
    if global_position.y < -8.0:
        global_position = spawn_position
        velocity = Vector3.ZERO
    update_visual(delta)

func _unhandled_key_input(event: InputEvent) -> void:
    if player_controlled and match_active and not defeated_state and event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE or event.keycode == KEY_A:
            jump_requested = true
        elif event.keycode == KEY_X:
            request_attack()
        elif event.keycode == KEY_B:
            request_pose("Block", 0.5)
        elif event.keycode == KEY_Y:
            request_pose("Parry", 0.4)
