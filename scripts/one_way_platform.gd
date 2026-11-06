extends StaticBody3D

## Godot 3D has no built-in one-way shape: filter each fighter independently.
## Feet below the top and upward motion pass through; descending feet land.
var fighters: Array[CharacterBody3D] = []

func _ready() -> void:
    for candidate in get_parent().get_children():
        if candidate is CharacterBody3D:
            fighters.append(candidate)

func _physics_process(_delta: float) -> void:
    var top := global_position.y + global_transform.basis.y.length() * 0.5
    for fighter in fighters:
        if is_instance_valid(fighter):
            if fighter.global_position.y < top - 0.08 or fighter.velocity.y > 0.1:
                add_collision_exception_with(fighter)
            else:
                remove_collision_exception_with(fighter)
