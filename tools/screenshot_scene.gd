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
var _call := ""
var _args: Array = []
var _wait := 1.2


func _initialize() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--scene="):
            _scene_path = arg.trim_prefix("--scene=")
        elif arg.begins_with("--out="):
            _out_path = arg.trim_prefix("--out=")
        elif arg.begins_with("--call="):
            _call = arg.trim_prefix("--call=")
        elif arg.begins_with("--args="):
            for part in arg.trim_prefix("--args=").split(",", false):
                _args.append(part.to_int() if part.is_valid_int() else part)
        elif arg.begins_with("--wait="):
            _wait = maxf(0.2, arg.trim_prefix("--wait=").to_float())

    var packed: PackedScene = load(_scene_path)
    if packed == null:
        push_error("Cannot load scene: " + _scene_path)
        quit(1)
        return
    var instance := packed.instantiate()
    root.add_child(instance)
    if not _call.is_empty():
        # e.g. --call=_on_start_battle to capture the post-battle state
        var call_timer := Timer.new()
        call_timer.one_shot = true
        call_timer.wait_time = 0.6
        call_timer.autostart = true
        call_timer.timeout.connect(func(): instance.callv(_call, _args))
        root.add_child(call_timer)

    var timer := Timer.new()
    timer.one_shot = true
    timer.wait_time = _wait
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
