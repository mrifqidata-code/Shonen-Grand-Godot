# tools/render_style_samples.gd
# Renders every character display style to PNG so the art direction can be
# compared outside the game.
#
# Run:
#   godot --headless --path <project> --script res://tools/render_style_samples.gd
extends SceneTree

const Factory := preload("res://scripts/services/character_sprite_factory.gd")
const ORIGINS := ["Naruto", "Jujutsu Kaisen", "Bleach", "One Piece", "One Punch Man"]


func _initialize() -> void:
    var out_dir := "res://assets/sprites/style_samples"
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))

    for style in Factory.get_styles():
        var sid := str(style["id"])
        for origin in ORIGINS:
            var img: Image = Factory.make_image(sid, origin)
            if img == null:
                push_error("Failed to render %s / %s" % [sid, origin])
                continue
            var slug := str(origin).to_lower().replace(" ", "_")
            var path := "%s/%s_%s.png" % [out_dir, sid, slug]
            var err := img.save_png(path)
            print("%s -> %s (%d)" % [path, error_string(err), img.get_width()])

    quit()
