extends Node3D

## Arena owns presentation. Fighters own movement; match rules will remain separate.
@onready var player = $Frost

func _ready() -> void:
    $Interface/ReferenceButton.pressed.connect(_open_reference)
    $Interface/Left.button_down.connect(func() -> void: player.move_input = -1.0)
    $Interface/Left.button_up.connect(func() -> void: player.move_input = 0.0)
    $Interface/Right.button_down.connect(func() -> void: player.move_input = 1.0)
    $Interface/Right.button_up.connect(func() -> void: player.move_input = 0.0)
    $Interface/Attack.pressed.connect(player.request_attack)
    $Interface/Jump.pressed.connect(func() -> void: player.jump_requested = true)

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
        if is_instance_valid(player):
            player.move_input = 0.0
            player.jump_requested = false

func _open_reference() -> void:
    get_tree().change_scene_to_file("res://scenes/arena.tscn")
