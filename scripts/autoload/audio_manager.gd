# scripts/autoload/audio_manager.gd
extends Node

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready():
    bgm_player = AudioStreamPlayer.new()
    bgm_player.bus = "Master"
    add_child(bgm_player)
    
    sfx_player = AudioStreamPlayer.new()
    sfx_player.bus = "Master"
    add_child(sfx_player)

func play_bgm(stream: AudioStream):
    if bgm_player.stream != stream:
        bgm_player.stream = stream
        bgm_player.play()

func stop_bgm():
    bgm_player.stop()

func play_sfx(stream: AudioStream):
    sfx_player.stream = stream
    sfx_player.play()
