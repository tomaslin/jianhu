extends SceneTree

const GameScene=preload("res://scenes/main.tscn")

func _initialize() -> void:call_deferred("run")

func run() -> void:
    var game=GameScene.instantiate()
    root.add_child(game)
    await process_frame
    var productive=0
    for world in range(8):
        game.start_dream(world)
        game._begin_aim()
        game.launch_x=195
        game.aim_angle=-.13 if world%2==0 else .21
        game._launch()
        await create_timer(3.4).timeout
        var earned:int=game.earnings_drop
        if earned>0:productive+=1
        print("WORLD ",world+1," / ",game.world_data.name," / taels=",earned," / combo=",game.combo_count," / pearls=",game.active_pearls.size())
        for pearl in game.active_pearls.duplicate():
            game._settle_pearl(pearl)
        game._end_drop()
    game.queue_free()
    await process_frame
    await process_frame
    await process_frame
    print("PHYSICS PLAYTEST: ",productive," / 8 worlds earned silver in 3.4s")
    quit(0 if productive==8 else 2)
