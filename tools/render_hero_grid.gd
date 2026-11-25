# tools/render_hero_grid.gd
# Renders every hero template with the procedural sprite factory into one
# contact sheet so all designs can be reviewed at once (no device needed).
#
#   godot --headless --path . --script res://tools/render_hero_grid.gd
#
# Output: res://screenshots/hero_art_grid.png
# Order: row-major, 5 per row, same order as scripts/data/heroes_data.gd:
#   Naruto Sasuke Kakashi Gojo Yuji
#   Sukuna Ichigo Rukia Aizen Luffy
#   Zoro Sanji Saitama Genos Tatsumaki
extends SceneTree

const Factory := preload("res://scripts/services/character_sprite_factory.gd")
const Heroes := preload("res://scripts/data/heroes_data.gd")

const CELL := 128
const COLS := 5
const PAD := 6
const STYLE := "px64"


func _initialize() -> void:
    var templates: Array = Heroes.get_all_templates()
    if templates.is_empty():
        push_error("no hero templates")
        quit(1)
        return

    var rows := int(ceil(float(templates.size()) / float(COLS)))
    var width := COLS * (CELL + PAD) + PAD
    var height := rows * (CELL + PAD) + PAD

    var sheet := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
    sheet.fill(Color(0.055, 0.064, 0.102, 1.0))

    for i in range(templates.size()):
        var t: Dictionary = templates[i]
        var hero_id := str(t["id"])
        var origin := str(t.get("anime_origin", "Default"))
        var sprite := Factory.make_image(STYLE, origin, hero_id)
        if sprite == null:
            push_warning("no sprite for " + hero_id)
            continue
        sprite.resize(CELL, CELL, Image.INTERPOLATE_NEAREST)

        var col := i % COLS
        var row := i / COLS
        var pos := Vector2i(PAD + col * (CELL + PAD), PAD + row * (CELL + PAD))
        sheet.blend_rect(sprite, Rect2i(Vector2i.ZERO, Vector2i(CELL, CELL)), pos)
        print("%02d  %-16s %s" % [i + 1, hero_id, t.get("hero_name", "")])

    var out := "res://screenshots/hero_art_grid.png"
    var err := sheet.save_png(out)
    if err != OK:
        push_error("cannot save " + out + " (" + str(err) + ")")
        quit(1)
        return
    print("saved %s (%d x %d)" % [out, width, height])
    quit(0)
