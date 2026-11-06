extends CharacterBody3D

## Prototype controller. The simulation plane is X/Y; Z never drives gameplay.
@export var player_controlled := true
@export var move_speed := 7.0
@export var jump_speed := 11.0
@export var gravity := 26.0
@export var spawn_position := Vector3(-4, 0.6, 0)
var move_input := 0.0
var jump_requested := false

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

func _unhandled_key_input(event: InputEvent) -> void:
    if player_controlled and event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE or event.keycode == KEY_A:
            jump_requested = true
