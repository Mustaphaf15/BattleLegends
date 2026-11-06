extends Node3D

## Arena coordinates baseline rounds; formal modes arrive in task08.
@onready var player = $Frost
@onready var bot = $Bot
var match_finished := false

func _ready() -> void:
    player.opponent = bot
    bot.opponent = player
    player.defeated.connect(_on_defeated)
    bot.defeated.connect(_on_defeated)
    $Interface/ReferenceButton.pressed.connect(_open_reference)
    $Interface/Left.button_down.connect(func() -> void: player.move_input = -1.0)
    $Interface/Left.button_up.connect(func() -> void: player.move_input = 0.0)
    $Interface/Right.button_down.connect(func() -> void: player.move_input = 1.0)
    $Interface/Right.button_up.connect(func() -> void: player.move_input = 0.0)
    $Interface/Attack.pressed.connect(player.request_attack)
    $Interface/Jump.pressed.connect(func() -> void: player.jump_requested = true)
    $Interface/Replay.pressed.connect(restart_match)

func _process(_delta: float) -> void:
    $Interface/PlayerHealth.value = player.health
    $Interface/BotHealth.value = bot.health

func _on_defeated(fighter) -> void:
    if match_finished:
        return
    match_finished = true
    player.match_active = false
    bot.match_active = false
    player.attack_pending = false
    bot.attack_pending = false
    $Interface/MatchMessage.text = "VICTOIRE !" if fighter == bot else "DÉFAITE !"
    $Interface/Replay.show()

func restart_match() -> void:
    match_finished = false
    player.reset_fighter()
    bot.reset_fighter()
    $Interface/MatchMessage.text = "FROST VS CINDER WARDEN"
    $Interface/Replay.hide()

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
        if is_instance_valid(player):
            player.move_input = 0.0
            player.jump_requested = false

func _open_reference() -> void:
    get_tree().change_scene_to_file("res://scenes/arena.tscn")
