# tools/screenshot_scene.gd
# Renders one UI scene and saves a PNG screenshot. Useful for reviewing layout
# without a device.
#
# Run (windowed, not headless):
#   godot --path <project> --rendering-driver opengl3 --resolution 720x1280 \
#         --script res://tools/screenshot_scene.gd -- --scene=res://scenes/ui/character_style.tscn --out=res://screenshots/style.png
extends SceneTree

var _scene_path := "res://scenes/ui/character_style.tscn"
var _out_path := "res://screenshots/screenshot.png"


func _initialize() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--scene="):
            _scene_path = arg.trim_prefix("--scene=")
        elif arg.begins_with("--out="):
            _out_path = arg.trim_prefix("--out=")

    var packed: PackedScene = load(_scene_path)
    if packed == null:
        push_error("Cannot load scene: " + _scene_path)
        quit(1)
        return
    root.add_child(packed.instantiate())

    var timer := Timer.new()
    timer.one_shot = true
    timer.wait_time = 1.2
    timer.autostart = true
    timer.timeout.connect(_capture)
    root.add_child(timer)


func _capture() -> void:
    var img := root.get_texture().get_image()
    var dir := _out_path.get_base_dir()
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
    var err := img.save_png(_out_path)
    print("screenshot %s -> %s (%d x %d)" % [_out_path, error_string(err), img.get_width(), img.get_height()])
    quit()
