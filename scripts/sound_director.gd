extends Node

# Eight original pentatonic beds, each composed at the scroll's own tempo.
# Short samples sit above the music; physics never waits for an audio event.
var main:Node2D
var music_player:AudioStreamPlayer
var impact_players:Array[AudioStreamPlayer]=[]
var stream_cache:Dictionary={}
var impact_cursor:int=0

func _ready() -> void:
    music_player=AudioStreamPlayer.new()
    music_player.bus="Master"
    music_player.volume_db=-18.0
    add_child(music_player)
    music_player.finished.connect(_restart_music)
    for i in range(7):
        var player:=AudioStreamPlayer.new()
        player.volume_db=-7.5
        add_child(player)
        impact_players.append(player)

func _restart_music() -> void:
    if main.music_on and music_player.stream!=null and main.phase!="menu":
        music_player.play()

func silence_all() -> void:
    if music_player!=null:
        music_player.stop()
        music_player.stream=null
    for voice in impact_players:
        if is_instance_valid(voice):
            voice.stop()
            voice.stream=null
    stream_cache.clear()

func _exit_tree() -> void:
    silence_all()

func change_world(index:int) -> void:
    var path="res://assets/audio/scroll_%02d.wav"%(index+1)
    if ResourceLoader.exists(path):
        music_player.stream=load(path)
        if main.music_on:music_player.play()

func set_music_enabled(enabled:bool) -> void:
    if enabled:
        if music_player.stream!=null and not music_player.playing:music_player.play()
    else:music_player.stop()

func _fx(name:String,pitch:float=1.0,gain:float=0.0) -> void:
    if impact_players.is_empty():return
    var path="res://assets/audio/fx_%s.wav"%name
    if not stream_cache.has(path):
        if not ResourceLoader.exists(path):return
        stream_cache[path]=load(path)
    var player=impact_players[impact_cursor%impact_players.size()]
    impact_cursor+=1
    player.stream=stream_cache[path]
    player.pitch_scale=clampf(pitch,.6,2.0)
    player.volume_db=gain-3.0 if main.reduce_motion else gain
    player.play()

func play_drop() -> void:_fx("drop",1.0)
func play_select() -> void:_fx("tap",1.0,-8)
func play_place() -> void:_fx("place",1.0)
func play_magic() -> void:_fx("magic",1.0)
func play_uproar(tier:int) -> void:
    if not main.spectacle_on:return
    # Three separately pitched original samples form a deliberately ridiculous
    # percussion stab. Each layer uses a different pooled voice, so the game
    # stays responsive during a dense physics cascade.
    _fx("blade",1.14+float(tier)*.12,1.0)
    _fx("bell",.89+float(tier)*.16,3.0)
    _fx("magic",1.0+float(tier)*.07,1.0)
func on_settle() -> void:_fx("settle",1.0)
func on_tribute() -> void:_fx("tribute",1.0)
func on_loss() -> void:_fx("loss",1.0)

func play_impact(kind:String,combo:int,onbeat:bool) -> void:
    var n:int=mini(10,combo)
    var voice="wood"
    if kind in ["bell","beads","wheel"]:voice="bell"
    if kind in ["mask","ghost","gate","moon","cloud"]:voice="magic"
    if kind in ["swords","bamboo","fan"]:voice="blade"
    var gain:float=-6.0 if combo<3 else (-1.0 if combo<10 else 1.5)
    if main.spectacle_on and combo>=15 and combo%5==0:
        _fx("tap",1.25+.02*float(n),-2)
    _fx(voice,1.0+.043*float(n)+(.12 if onbeat else 0.0),gain)

func on_beat(beat:int) -> void:
    # Once a riot starts, the beat itself joins the percussion section.
    # Idle days remain painterly and quiet, without a perpetual metronome.
    if main.spectacle_on and main.mayhem_timer>0 and beat%2==0:
        _fx("tap",1.08+float(main.mayhem_tier)*.12,-13)
