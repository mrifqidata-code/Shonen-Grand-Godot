# scripts/ui/character_style_ui.gd
# "Gaya Tampilan Karakter" screen.
# Shows the same character in 5 resolutions/styles so the look can be compared
# at real phone size before committing to an art pipeline.
extends Control

const Factory := preload("res://scripts/services/character_sprite_factory.gd")
const CharacterViewScript := preload("res://scripts/ui/character_view.gd")

const SAMPLE_HEROES := [
    {"label": "Naruto", "origin": "Naruto"},
    {"label": "Gojo", "origin": "Jujutsu Kaisen"},
    {"label": "Ichigo", "origin": "Bleach"},
    {"label": "Luffy", "origin": "One Piece"},
]

@onready var style_list: VBoxContainer = $VBox/Scroll/StyleList
@onready var footer: Label = $VBox/Footer

var _preview_views: Array = []
var _apply_buttons: Array = []


func _ready() -> void:
    $VBox/Header/BackBtn.pressed.connect(
        func(): SceneManager.change_scene("res://scenes/main.tscn")
    )
    _build()


func _build() -> void:
    for child in style_list.get_children():
        child.queue_free()
    _preview_views.clear()
    _apply_buttons.clear()

    style_list.add_child(_make_preview_card())
    for style in Factory.get_styles():
        style_list.add_child(_make_style_card(style))
    style_list.add_child(_make_guide_card())
    _update_footer()


func _make_preview_card() -> PanelContainer:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override(
        "panel", _panel_style(Color(0.10, 0.11, 0.20), Color(0.32, 0.38, 0.68))
    )

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 8)
    panel.add_child(box)

    var title := Label.new()
    title.text = "Pratinjau ukuran asli di HP (720 × 1280)"
    title.add_theme_font_size_override("font_size", 13)
    title.add_theme_color_override("font_color", Color(0.72, 0.76, 0.88))
    box.add_child(title)

    var row := HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.add_theme_constant_override("separation", 10)
    box.add_child(row)

    var current := GameManager.get_character_style()
    for hero in SAMPLE_HEROES:
        var col := VBoxContainer.new()
        col.add_theme_constant_override("separation", 2)
        var view = CharacterViewScript.new()
        view.custom_minimum_size = Vector2(82, 82)
        view.style_id = current
        view.anime_origin = hero["origin"]
        col.add_child(view)

        var name_label := Label.new()
        name_label.text = hero["label"]
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 10)
        name_label.add_theme_color_override("font_color", Color(0.7, 0.72, 0.8))
        col.add_child(name_label)

        row.add_child(col)
        _preview_views.append(view)

    return panel


func _make_style_card(style: Dictionary) -> PanelContainer:
    var is_active: bool = GameManager.get_character_style() == str(style["id"])
    var border := Color(0.24, 0.27, 0.40)
    if is_active:
        border = Color(0.35, 0.90, 0.60)
    elif style["recommended"]:
        border = Color(0.85, 0.68, 0.20)

    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.16), border))

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    panel.add_child(row)

    var frame := PanelContainer.new()
    frame.custom_minimum_size = Vector2(92, 92)
    frame.add_theme_stylebox_override(
        "panel", _panel_style(Color(0.14, 0.15, 0.24), Color(0, 0, 0, 0), 8, 6)
    )
    var view = CharacterViewScript.new()
    view.custom_minimum_size = Vector2(92, 92)
    view.style_id = style["id"]
    view.anime_origin = "Naruto"
    frame.add_child(view)
    row.add_child(frame)

    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.add_theme_constant_override("separation", 2)
    row.add_child(info)

    var name_label := Label.new()
    name_label.text = str(style["label"])
    if style["recommended"]:
        name_label.text += "  ⭐ rekomendasi"
    name_label.add_theme_font_size_override("font_size", 15)
    info.add_child(name_label)

    var meta := Label.new()
    meta.text = "%s · %d × %d px · %.0f KB" % [
        str(style["tagline"]),
        int(style["native"]),
        int(style["native"]),
        float(Factory.memory_bytes(style["id"])) / 1024.0,
    ]
    meta.add_theme_font_size_override("font_size", 10)
    meta.add_theme_color_override("font_color", Color(0.60, 0.64, 0.76))
    meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_child(meta)

    var desc := Label.new()
    desc.text = str(style["desc"])
    desc.add_theme_font_size_override("font_size", 11)
    desc.add_theme_color_override("font_color", Color(0.72, 0.74, 0.82))
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_child(desc)

    var apply_btn := Button.new()
    apply_btn.text = "✅ Aktif" if is_active else "Pakai gaya ini"
    apply_btn.disabled = is_active
    apply_btn.custom_minimum_size = Vector2(0, 34)
    apply_btn.pressed.connect(_on_apply.bind(str(style["id"])))
    info.add_child(apply_btn)

    _apply_buttons.append({
        "id": str(style["id"]),
        "button": apply_btn,
        "panel": panel,
        "recommended": bool(style["recommended"]),
    })

    return panel


func _make_guide_card() -> PanelContainer:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override(
        "panel", _panel_style(Color(0.07, 0.08, 0.14), Color(0.22, 0.25, 0.38))
    )

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 6)
    panel.add_child(box)

    var title := Label.new()
    title.text = "Cara memilih (singkat)"
    title.add_theme_font_size_override("font_size", 14)
    box.add_child(title)

    var body := Label.new()
    body.text = (
        "• Di layar 720 × 1280, hero di baris battle tampil ± 96–128 px.\n"
        + "• 16/32 px → gaya retro; wajah jadi blok. Hanya kalau memang mau nuansa pixel.\n"
        + "• 64 px → pixel detail, outline rapi, hemat memori (16 KB/hero).\n"
        + "• 128 px → rekomendasi anime idle RPG: halus, kecil (64 KB/hero).\n"
        + "• 256 px → paling tajam, 256 KB/hero (6 hero = 1,5 MB VRAM).\n"
        + "• Animasi: pixel style pakai sprite sheet 4–8 frame; HD chibi cocok untuk tween/bone atau Live2D-style.\n"
        + "• Ganti art nanti: taruh Canva di res://assets/sprites/heroes/<asal>/<id_gaya>.png — otomatis dipakai."
    )
    body.add_theme_font_size_override("font_size", 11)
    body.add_theme_color_override("font_color", Color(0.74, 0.76, 0.84))
    body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(body)

    return panel


func _panel_style(bg: Color, border: Color, radius: int = 10, margin: int = 10) -> StyleBoxFlat:
    var sb := StyleBoxFlat.new()
    sb.bg_color = bg
    sb.border_color = border
    sb.set_border_width_all(2)
    sb.set_corner_radius_all(radius)
    sb.set_content_margin_all(margin)
    return sb


func _on_apply(style_id: String) -> void:
    GameManager.set_character_style(style_id)

    for view in _preview_views:
        view.style_id = style_id

    for entry in _apply_buttons:
        var is_active: bool = entry["id"] == style_id
        var btn: Button = entry["button"]
        btn.text = "✅ Aktif" if is_active else "Pakai gaya ini"
        btn.disabled = is_active

        var border := Color(0.24, 0.27, 0.40)
        if is_active:
            border = Color(0.35, 0.90, 0.60)
        elif entry["recommended"]:
            border = Color(0.85, 0.68, 0.20)
        var panel: PanelContainer = entry["panel"]
        panel.add_theme_stylebox_override(
            "panel", _panel_style(Color(0.08, 0.09, 0.16), border)
        )

    _update_footer()


func _update_footer() -> void:
    footer.text = "Gaya aktif: %s — dipakai di kartu hero, battle, dan pratinjau." % Factory.label_for(
        GameManager.get_character_style()
    )
