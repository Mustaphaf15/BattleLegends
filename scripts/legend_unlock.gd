extends Control

# Prototype de deblocage de Legend, 120 secondes.
# Ajouter le fichier WAV instrumental a res://audio/legend_kick_overload_2_minutes.wav
@onready var music: AudioStreamPlayer = $Music
@onready var finish_timer: Timer = $FinishTimer
@onready var message: Label = $Center/Message

func _ready() -> void:
    finish_timer.timeout.connect(_finish_unlock)
    var audio_path := "res://audio/legend_kick_overload_2_minutes.wav"
    if ResourceLoader.exists(audio_path):
        music.stream = load(audio_path)
        music.play()
    finish_timer.start()

func _process(_delta: float) -> void:
    var elapsed: float = 120.0 - finish_timer.time_left
    if elapsed < 12.0:
        message.text = "LEGEND - THE AWAKENING"
    elif elapsed < 30.0:
        message.text = "HELLO, MASTER."
    elif elapsed < 90.0:
        message.text = "THE FINAL BATTLE"
    elif elapsed < 115.0:
        message.text = "PERFECT PUNISH"
    else:
        message.text = "LEGEND"

func _finish_unlock() -> void:
    music.stop()
    message.text = "LEGEND UNLOCKED!"
