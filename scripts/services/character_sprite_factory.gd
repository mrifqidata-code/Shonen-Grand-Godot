# scripts/services/character_sprite_factory.gd
# Placeholder character renderer.
# Draws a chibi figure procedurally at several resolutions so we can compare
# art styles (16px pixel, 32px pixel, 64px pixel, 128px HD, 256px HD) BEFORE
# real Canva art is imported.
#
# Every style uses the SAME silhouette, so the comparison is apples-to-apples.
# Replace with real art later: CharacterView will fall back to
# res://assets/sprites/heroes/<origin>/<style>.png when the file exists.
extends RefCounted
class_name CharacterSpriteFactory

const DEFAULT_STYLE := "chibi128"

static var _cache: Dictionary = {}

static var _palettes: Dictionary = {
    "Naruto": {
        "hair": Color("f2c53d"),
        "skin": Color("f4cba6"),
        "outfit": Color("e8722c"),
        "outfit_dark": Color("a94a17"),
        "accent": Color("2d5be3"),
        "eye": Color("22283c"),
    },
    "One Piece": {
        "hair": Color("2b2b33"),
        "skin": Color("e9b98d"),
        "outfit": Color("d33b3b"),
        "outfit_dark": Color("8c1d1d"),
        "accent": Color("f2d15b"),
        "eye": Color("1d1d24"),
    },
    "Bleach": {
        "hair": Color("22222c"),
        "skin": Color("f0d3b8"),
        "outfit": Color("f2f2f6"),
        "outfit_dark": Color("b3b3c2"),
        "accent": Color("5aa9ff"),
        "eye": Color("24303f"),
    },
    "Jujutsu Kaisen": {
        "hair": Color("e9e9f4"),
        "skin": Color("f2cfae"),
        "outfit": Color("232a40"),
        "outfit_dark": Color("10131f"),
        "accent": Color("7a4cff"),
        "eye": Color("6c8dff"),
    },
    "One Punch Man": {
        "hair": Color("2a2a33"),
        "skin": Color("f0c39c"),
        "outfit": Color("f4d13c"),
        "outfit_dark": Color("b8921a"),
        "accent": Color("d63a3a"),
        "eye": Color("23232b"),
    },
    "Enemy": {
        "hair": Color("3b2a4d"),
        "skin": Color("b6a3c6"),
        "outfit": Color("2a2140"),
        "outfit_dark": Color("161022"),
        "accent": Color("a45cff"),
        "eye": Color("ff5d7a"),
    },
    "Default": {
        "hair": Color("3b3f5c"),
        "skin": Color("f0c9a6"),
        "outfit": Color("4f7bd9"),
        "outfit_dark": Color("2b4a94"),
        "accent": Color("f2c14e"),
        "eye": Color("22283c"),
    },
}


static func get_styles() -> Array:
    return [
        {
            "id": "px16",
            "label": "Pixel 16 × 16",
            "native": 16,
            "antialias": false,
            "detail": 0,
            "tagline": "Retro 8-bit · paling ringan",
            "desc": "Sprite 16 × 16 diperbesar ±6×. Hemat memori, tapi wajah dan kostum tidak terbaca di layar HP.",
            "recommended": false,
        },
        {
            "id": "px32",
            "label": "Pixel 32 × 32",
            "native": 32,
            "antialias": false,
            "detail": 1,
            "tagline": "Pixel klasik · mulai terbaca",
            "desc": "Sprite 32 × 32. Siluet jelas, mata masih 1 piksel. Cocok untuk game retro, kurang cocok untuk anime.",
            "recommended": false,
        },
        {
            "id": "px64",
            "label": "Pixel 64 × 64",
            "native": 64,
            "antialias": false,
            "detail": 2,
            "tagline": "Pixel detail · seimbang",
            "desc": "Sprite 64 × 64 dengan outline. Ekspresi terbaca, memori kecil (16 KB per hero). Pilihan aman kalau mau nuansa pixel.",
            "recommended": false,
        },
        {
            "id": "chibi128",
            "label": "Chibi HD 128 × 128",
            "native": 128,
            "antialias": true,
            "detail": 3,
            "tagline": "Rekomendasi · anime chibi halus",
            "desc": "Sprite 128 × 128 anti-alias, garis halus, cocok gaya anime idle RPG modern. Ukuran tampil di HP ± 96-128 px.",
            "recommended": true,
        },
        {
            "id": "hd256",
            "label": "Anime HD 256 × 256",
            "native": 256,
            "antialias": true,
            "detail": 4,
            "tagline": "Paling tajam · memori besar",
            "desc": "Sprite 256 × 256 + aura. Paling tajam untuk hero besar / layar 1080p, tapi 256 KB per hero (6 hero = 1,5 MB VRAM).",
            "recommended": false,
        },
    ]


static func get_default_style() -> Dictionary:
    for style in get_styles():
        if style["id"] == DEFAULT_STYLE:
            return style
    return get_styles()[3]


static func get_style(style_id: String) -> Dictionary:
    for style in get_styles():
        if style["id"] == style_id:
            return style
    return get_default_style()


static func is_nearest(style_id: String) -> bool:
    return not bool(get_style(style_id)["antialias"])


static func label_for(style_id: String) -> String:
    return str(get_style(style_id)["label"])


static func native_size(style_id: String) -> int:
    return int(get_style(style_id)["native"])


# Uncompressed RGBA8 footprint in bytes.
static func memory_bytes(style_id: String) -> int:
    var n := native_size(style_id)
    return n * n * 4


static func origin_keys() -> Array:
    var keys: Array = _palettes.keys()
    keys.erase("Default")
    keys.sort()
    return keys


static func make_texture(style_id: String, origin: String = "Default") -> Texture2D:
    var key := "%s|%s" % [style_id, origin]
    if _cache.has(key):
        return _cache[key]
    var img := make_image(style_id, origin)
    if img == null:
        return null
    var tex := ImageTexture.create_from_image(img)
    _cache[key] = tex
    return tex


static func make_image(style_id: String, origin: String = "Default") -> Image:
    var style := get_style(style_id)
    var n := int(style["native"])
    var aa := bool(style["antialias"])
    var detail := int(style["detail"])
    var pal: Dictionary = _palette_for(origin)

    var fig := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)

    # ---- legs -------------------------------------------------------------
    _rrect(fig, Rect2(n * 0.33, n * 0.82, n * 0.135, n * 0.16), n * 0.05, pal["outfit_dark"], aa)
    _rrect(fig, Rect2(n * 0.535, n * 0.82, n * 0.135, n * 0.16), n * 0.05, pal["outfit_dark"], aa)

    # ---- arms -------------------------------------------------------------
    _rrect(fig, Rect2(n * 0.195, n * 0.605, n * 0.125, n * 0.235), n * 0.055, pal["outfit"], aa)
    _rrect(fig, Rect2(n * 0.68, n * 0.605, n * 0.125, n * 0.235), n * 0.055, pal["outfit"], aa)

    # ---- torso ------------------------------------------------------------
    _rrect(fig, Rect2(n * 0.30, n * 0.565, n * 0.40, n * 0.285), n * 0.09, pal["outfit"], aa)
    if detail >= 2:
        # belt
        _rrect(fig, Rect2(n * 0.30, n * 0.775, n * 0.40, n * 0.05), n * 0.02, pal["outfit_dark"], aa)
    if detail >= 3:
        # collar + outfit highlight
        _rrect(fig, Rect2(n * 0.38, n * 0.575, n * 0.24, n * 0.055), n * 0.02, pal["accent"], aa)
        _rrect(
            fig,
            Rect2(n * 0.335, n * 0.625, n * 0.075, n * 0.13),
            n * 0.035,
            Color(1.0, 1.0, 1.0, 0.14),
            aa,
        )

    # ---- head -------------------------------------------------------------
    var face_center := Vector2(n * 0.5, n * 0.375)
    _circle(fig, face_center, n * 0.215, pal["skin"], aa)

    # hair cap: same circle as the head but higher, clipped just above the eyes
    _circle(fig, Vector2(n * 0.5, n * 0.325), n * 0.25, pal["hair"], aa, n * 0.415)

    if detail >= 2:
        # side hair + fringe strands give the silhouette character
        _circle(fig, Vector2(n * 0.285, n * 0.435), n * 0.078, pal["hair"], aa)
        _circle(fig, Vector2(n * 0.715, n * 0.435), n * 0.078, pal["hair"], aa)
        _circle(fig, Vector2(n * 0.345, n * 0.20), n * 0.072, pal["hair"], aa)
        _circle(fig, Vector2(n * 0.50, n * 0.145), n * 0.078, pal["hair"], aa)
        _circle(fig, Vector2(n * 0.655, n * 0.20), n * 0.072, pal["hair"], aa)
        _circle(fig, Vector2(n * 0.395, n * 0.355), n * 0.072, pal["hair"], aa)
        _circle(fig, Vector2(n * 0.605, n * 0.355), n * 0.072, pal["hair"], aa)

    if detail >= 3:
        # hair highlight
        _circle(fig, Vector2(n * 0.425, n * 0.245), n * 0.07, Color(1.0, 1.0, 1.0, 0.30), aa)

    # headband for ninja-style origin (extra detail level only)
    if detail >= 2 and str(origin) == "Naruto":
        _rrect(fig, Rect2(n * 0.285, n * 0.298, n * 0.43, n * 0.055), n * 0.012, pal["accent"], aa)
        _rrect(fig, Rect2(n * 0.44, n * 0.298, n * 0.12, n * 0.055), n * 0.008, Color("c9ccd6"), aa)

    # ---- face -------------------------------------------------------------
    if detail >= 1:
        var eye_r := n * 0.032
        _circle(fig, Vector2(n * 0.435, n * 0.465), eye_r, pal["eye"], aa)
        _circle(fig, Vector2(n * 0.565, n * 0.465), eye_r, pal["eye"], aa)
    if detail >= 3:
        _circle(fig, Vector2(n * 0.428, n * 0.456), n * 0.012, Color(1, 1, 1, 0.9), aa)
        _circle(fig, Vector2(n * 0.558, n * 0.456), n * 0.012, Color(1, 1, 1, 0.9), aa)
        # blush + mouth
        _circle(fig, Vector2(n * 0.368, n * 0.505), n * 0.032, Color(0.95, 0.45, 0.5, 0.28), aa)
        _circle(fig, Vector2(n * 0.632, n * 0.505), n * 0.032, Color(0.95, 0.45, 0.5, 0.28), aa)
        _rrect(
            fig,
            Rect2(n * 0.472, n * 0.527, n * 0.056, n * 0.014),
            n * 0.007,
            Color(0.25, 0.18, 0.2, 0.75),
            aa
        )

    # ---- outline ----------------------------------------------------------
    if detail >= 2:
        _outline(fig, Color(0.03, 0.04, 0.09, 0.9))

    # ---- composite (aura goes behind the figure) --------------------------
    var img := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)
    if detail >= 4:
        var accent: Color = pal["accent"]
        var aura := Color(accent.r, accent.g, accent.b, 0.10)
        _circle(img, Vector2(n * 0.5, n * 0.60), n * 0.47, aura, aa)
        _circle(img, Vector2(n * 0.5, n * 0.60), n * 0.40, aura, aa)

    img.blend_rect(fig, Rect2i(Vector2i.ZERO, Vector2i(n, n)), Vector2i.ZERO)
    return img


static func _palette_for(origin: String) -> Dictionary:
    if _palettes.has(origin):
        return _palettes[origin]
    return _palettes["Default"]


# Source-over blend of `col` with coverage `a` into a single pixel.
static func _blend(img: Image, x: int, y: int, col: Color, a: float) -> void:
    var sa := clampf(a, 0.0, 1.0) * clampf(col.a, 0.0, 1.0)
    if sa <= 0.0:
        return
    var dst := img.get_pixel(x, y)
    var da := dst.a
    var oa := sa + da * (1.0 - sa)
    if oa <= 0.0001:
        return
    img.set_pixel(
        x,
        y,
        Color(
            (col.r * sa + dst.r * da * (1.0 - sa)) / oa,
            (col.g * sa + dst.g * da * (1.0 - sa)) / oa,
            (col.b * sa + dst.b * da * (1.0 - sa)) / oa,
            oa,
        )
    )


static func _circle(
    img: Image,
    c: Vector2,
    r: float,
    col: Color,
    aa: bool,
    clip_y_max: float = INF
) -> void:
    var n := img.get_width()
    if not aa:
        c = Vector2(floor(c.x) + 0.5, floor(c.y) + 0.5)
        r = maxf(floor(r), 0.5)
    var x0 := clampi(int(floor(c.x - r - 1.0)), 0, n - 1)
    var x1 := clampi(int(ceil(c.x + r + 1.0)), 0, n - 1)
    var y0 := clampi(int(floor(c.y - r - 1.0)), 0, n - 1)
    var y1 := clampi(int(ceil(c.y + r + 1.0)), 0, n - 1)
    for y in range(y0, y1 + 1):
        var py := y + 0.5
        if py > clip_y_max:
            continue
        var dy := py - c.y
        for x in range(x0, x1 + 1):
            var dx := (x + 0.5) - c.x
            var dist := sqrt(dx * dx + dy * dy)
            var cov := 1.0
            if aa:
                cov = clampf(r - dist + 0.5, 0.0, 1.0)
            else:
                cov = 1.0 if dist <= r else 0.0
            if cov > 0.0:
                _blend(img, x, y, col, cov)


static func _rrect(img: Image, rect: Rect2, radius: float, col: Color, aa: bool) -> void:
    var n := img.get_width()
    if not aa:
        rect = Rect2(
            round(rect.position.x),
            round(rect.position.y),
            maxf(1.0, round(rect.size.x)),
            maxf(1.0, round(rect.size.y))
        )
        radius = maxf(round(radius), 0.0)
    var center := rect.get_center()
    var half := rect.size * 0.5
    if half.x <= 0.0 or half.y <= 0.0:
        return
    var rr := minf(radius, minf(half.x, half.y))
    var x0 := clampi(int(floor(rect.position.x - 1.0)), 0, n - 1)
    var x1 := clampi(int(ceil(rect.end.x + 1.0)), 0, n - 1)
    var y0 := clampi(int(floor(rect.position.y - 1.0)), 0, n - 1)
    var y1 := clampi(int(ceil(rect.end.y + 1.0)), 0, n - 1)
    for y in range(y0, y1 + 1):
        var py := (y + 0.5) - center.y
        for x in range(x0, x1 + 1):
            var px := (x + 0.5) - center.x
            var qx := absf(px) - (half.x - rr)
            var qy := absf(py) - (half.y - rr)
            var mx := maxf(qx, 0.0)
            var my := maxf(qy, 0.0)
            var d := sqrt(mx * mx + my * my) + minf(maxf(qx, qy), 0.0) - rr
            var cov := 1.0
            if aa:
                cov = clampf(0.5 - d, 0.0, 1.0)
            else:
                cov = 1.0 if d <= 0.0 else 0.0
            if cov > 0.0:
                _blend(img, x, y, col, cov)


static func _outline(img: Image, col: Color) -> void:
    var w := img.get_width()
    var h := img.get_height()
    var src: Image = img.duplicate()
    for y in range(h):
        for x in range(w):
            if src.get_pixel(x, y).a > 0.05:
                continue
            var neighbour := 0.0
            if x > 0:
                neighbour = maxf(neighbour, src.get_pixel(x - 1, y).a)
            if x < w - 1:
                neighbour = maxf(neighbour, src.get_pixel(x + 1, y).a)
            if y > 0:
                neighbour = maxf(neighbour, src.get_pixel(x, y - 1).a)
            if y < h - 1:
                neighbour = maxf(neighbour, src.get_pixel(x, y + 1).a)
            if neighbour > 0.08:
                _blend(img, x, y, Color(col.r, col.g, col.b, 1.0), minf(neighbour, 1.0) * col.a)
