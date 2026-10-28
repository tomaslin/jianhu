extends SceneTree

# Optional visual smoke check; usable on desktop Godot with a rendering driver.
const GameScene=preload("res://scenes/main.tscn")

func _initialize() -> void:call_deferred("capture")

func capture() -> void:
    if DisplayServer.get_name()=="headless":
        print("Visual capture requires an actual display driver; headless test skipped.")
        quit()
        return
    var game=GameScene.instantiate()
    root.add_child(game)
    await process_frame
    await process_frame
    var image=root.get_texture().get_image()
    print("CAPTURE IMAGE: ",image.get_size())
    if image.get_width()>0:
        print("CAPTURE SAVED: ",image.save_png("user://jianghu_menu_capture.png"))
    game.start_dream(4)
    await process_frame
    await process_frame
    image=root.get_texture().get_image()
    if image.get_width()>0:
        print("BOARD CAPTURE SAVED: ",image.save_png("user://jianghu_board_capture.png"))
    game.queue_free()
    quit()
