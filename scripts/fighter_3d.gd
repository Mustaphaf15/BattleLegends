extends CharacterBody3D

## Prototype controller. The simulation plane is X/Y; Z never drives gameplay.
@export var player_controlled := true
@export var move_speed := 7.0
@export var jump_speed := 11.0
@export var gravity := 26.0
@export var spawn_position := Vector3(-4, 0.6, 0)
var move_input := 0.0
var jump_requested := false
var frost_visual: Node3D
var animation_state := "Idle"
var action_state := ""
var action_time := 0.0
var facing := 1.0

func _ready() -> void:
    if player_controlled:
        $Body.hide()
        frost_visual = Node3D.new()
        frost_visual.set_script(preload("res://scripts/frost_visual.gd"))
        frost_visual.name = "FrostVisual"
        add_child(frost_visual)

func request_attack() -> void:
    if action_time <= 0.0:
        request_pose("Attack", 0.4)

func request_pose(pose: String, duration: float) -> void:
    if pose in ["Attack", "Block", "Parry", "Hit", "KO"]:
        action_state = pose
        action_time = maxf(duration, 0.01)

func update_visual(delta: float) -> void:
    action_time = maxf(action_time - delta, 0.0)
    if action_time <= 0.0:
        action_state = ""
    if action_state != "":
        animation_state = action_state
    elif not is_on_floor():
        animation_state = "Jump" if velocity.y > 0.0 else "Fall"
    elif absf(velocity.x) > 0.1:
        animation_state = "Run"
    else:
        animation_state = "Idle"
    if absf(velocity.x) > 0.1:
        facing = signf(velocity.x)
    if is_instance_valid(frost_visual):
        frost_visual.scale.x = facing
        frost_visual.play_state(animation_state)

func _physics_process(delta: float) -> void:
    if player_controlled:
        var keyboard_axis := float(int(Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_Q)))
        var axis := keyboard_axis if not is_zero_approx(keyboard_axis) else move_input
        velocity.x = clampf(axis, -1.0, 1.0) * move_speed
        if jump_requested and is_on_floor():
            velocity.y = jump_speed
    else:
        velocity.x = 0.0
    jump_requested = false
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
    if player_controlled and event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE or event.keycode == KEY_A:
            jump_requested = true
        elif event.keycode == KEY_X:
            request_attack()
        elif event.keycode == KEY_B:
            request_pose("Block", 0.5)
        elif event.keycode == KEY_Y:
            request_pose("Parry", 0.4)
