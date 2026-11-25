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

const DEFAULT_STYLE := "px64"

# Animation clips shared by CharacterView and the battle playback.
# Frames are generated from the static portrait, so no art export is needed.
const ANIMS := {
    "idle": {"frames": 4, "fps": 4.0, "loop": true},
    "attack": {"frames": 6, "fps": 14.0, "loop": false},
    "hurt": {"frames": 3, "fps": 12.0, "loop": false},
    "victory": {"frames": 4, "fps": 6.0, "loop": false},
}

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
    "Dragon Ball": {
        "hair": Color("1d1d24"),
        "skin": Color("e8b184"),
        "outfit": Color("f08a24"),
        "outfit_dark": Color("b85e12"),
        "accent": Color("3a7bff"),
        "eye": Color("20242f"),
    },
    "Attack on Titan": {
        "hair": Color("4a3524"),
        "skin": Color("e7c09a"),
        "outfit": Color("5c6b3a"),
        "outfit_dark": Color("39441f"),
        "accent": Color("d8d2c0"),
        "eye": Color("2c3a2a"),
    },
    "Demon Slayer": {
        "hair": Color("7a2530"),
        "skin": Color("f2cba8"),
        "outfit": Color("23272e"),
        "outfit_dark": Color("14171c"),
        "accent": Color("3fa06b"),
        "eye": Color("b0463c"),
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


# Per-hero overrides so every owned hero looks different without any art files.
# Keyed by template id from scripts/data/heroes_data.gd. Missing fields fall back
# to the origin palette, so adding a hero needs no changes here.
static var _hero_styles: Dictionary = {
    "naruto_uzumaki": {
        "hair": Color("f2c53d"),
        "outfit": Color("e8722c"),
        "outfit_dark": Color("a94a17"),
        "accent": Color("2d5be3"),
        "eye": Color("2f6bd8"),
        "hair_style": "spiky",
        "accessories": ["headband"],
    },
    "sasuke_uchiha": {
        "hair": Color("24242e"),
        "outfit": Color("2c3a5e"),
        "outfit_dark": Color("1a2338"),
        "accent": Color("c4453f"),
        "eye": Color("d33a3a"),
        "hair_style": "spiky",
        "accessories": ["high_collar"],
    },
    "kakashi_hatake": {
        "hair": Color("c9ccd6"),
        "outfit": Color("3c5a3a"),
        "outfit_dark": Color("263c26"),
        "eye": Color("2b3445"),
        "hair_style": "spiky",
        "accessories": ["mask", "headband"],
    },
    "gojo_satoru": {
        "hair": Color("eef0f7"),
        "outfit": Color("1d2233"),
        "outfit_dark": Color("0f1320"),
        "accent": Color("6fd3ff"),
        "eye": Color("74c7ff"),
        "hair_style": "spiky",
        "accessories": ["blindfold"],
    },
    "yuji_itadori": {
        "hair": Color("f2a0b4"),
        "outfit": Color("232a40"),
        "outfit_dark": Color("141a2b"),
        "accent": Color("d94b4b"),
        "hair_style": "short",
    },
    "sukuna": {
        "hair": Color("e88fa8"),
        "skin": Color("e8c3a0"),
        "outfit": Color("2a1a24"),
        "outfit_dark": Color("170e15"),
        "accent": Color("e03a3a"),
        "eye": Color("e03a3a"),
        "hair_style": "spiky",
        "bare_chest": true,
        "accessories": ["face_marks"],
    },
    "ichigo_kurosaki": {
        "hair": Color("f28b2c"),
        "outfit": Color("16161c"),
        "outfit_dark": Color("0c0c11"),
        "accent": Color("5aa9ff"),
        "hair_style": "spiky",
        "accessories": ["sword"],
    },
    "rukia_kuchiki": {
        "hair": Color("1b1b24"),
        "outfit": Color("16161c"),
        "outfit_dark": Color("0c0c11"),
        "accent": Color("9c7bff"),
        "eye": Color("5a4a8c"),
        "hair_style": "bob",
        "accessories": ["sword"],
    },
    "aizen_sosuke": {
        "hair": Color("4a3524"),
        "outfit": Color("1a1a22"),
        "outfit_dark": Color("0e0e14"),
        "accent": Color("f2f2f6"),
        "eye": Color("4a3524"),
        "hair_style": "slick",
        "cape_color": Color("f2f2f6"),
        "accessories": ["glasses", "cape"],
    },
    "luffy_monkey": {
        "hair": Color("24242c"),
        "outfit": Color("d33b3b"),
        "outfit_dark": Color("8c1d1d"),
        "accent": Color("f2d15b"),
        "hair_style": "short",
        "accessories": ["straw_hat"],
    },
    "zoro_roronoa": {
        "hair": Color("4e9a52"),
        "outfit": Color("2f5f3a"),
        "outfit_dark": Color("1f3f26"),
        "accent": Color("e8e8ee"),
        "hair_style": "short",
        "accessories": ["sword"],
    },
    "sanji_vinsmoke": {
        "hair": Color("f2d15b"),
        "outfit": Color("1b1b22"),
        "outfit_dark": Color("101016"),
        "accent": Color("3a6bd6"),
        "hair_style": "swoop",
    },
    "saitama": {
        "hair": Color("f0c39c"),
        "outfit": Color("f4d13c"),
        "outfit_dark": Color("b8921a"),
        "accent": Color("d63a3a"),
        "cape_color": Color("f4f6fa"),
        "hair_style": "bald",
        "accessories": ["cape"],
    },
    "genos": {
        "hair": Color("f2c53d"),
        "skin": Color("b9bfcc"),
        "outfit": Color("1a1a20"),
        "outfit_dark": Color("0d0d12"),
        "accent": Color("f28b2c"),
        "eye": Color("f2b13c"),
        "hair_style": "spiky",
        "accessories": ["cyborg"],
    },
    "tatsumaki": {
        "hair": Color("4fbf7a"),
        "outfit": Color("1b1f2a"),
        "outfit_dark": Color("0f121a"),
        "accent": Color("6ff2b0"),
        "eye": Color("2f7a52"),
        "hair_style": "curly",
        "accessories": ["aura"],
    },
}


static func _hero_cfg(hero_id: String) -> Dictionary:
    if _hero_styles.has(hero_id):
        return _hero_styles[hero_id]
    return {}


static func _draw_hair(
    fig: Image, n: int, pal: Dictionary, hair_style: String, aa: bool, detail: int
) -> void:
    var hair: Color = pal["hair"]
    match hair_style:
        "bald":
            if detail >= 3:
                _circle(fig, Vector2(n * 0.435, n * 0.245), n * 0.060, Color(1, 1, 1, 0.28), aa)
        "curly":
            _circle(fig, Vector2(n * 0.5, n * 0.315), n * 0.245, hair, aa, n * 0.415)
            _circle(fig, Vector2(n * 0.265, n * 0.365), n * 0.105, hair, aa)
            _circle(fig, Vector2(n * 0.735, n * 0.365), n * 0.105, hair, aa)
            _circle(fig, Vector2(n * 0.345, n * 0.170), n * 0.095, hair, aa)
            _circle(fig, Vector2(n * 0.520, n * 0.120), n * 0.100, hair, aa)
            _circle(fig, Vector2(n * 0.670, n * 0.175), n * 0.090, hair, aa)
        "bob":
            _circle(fig, Vector2(n * 0.5, n * 0.315), n * 0.245, hair, aa, n * 0.415)
            _rrect(fig, Rect2(n * 0.255, n * 0.335, n * 0.115, n * 0.240), n * 0.050, hair, aa)
            _rrect(fig, Rect2(n * 0.630, n * 0.335, n * 0.115, n * 0.240), n * 0.050, hair, aa)
            _rrect(fig, Rect2(n * 0.330, n * 0.170, n * 0.340, n * 0.090), n * 0.040, hair, aa)
        "swoop":
            _circle(fig, Vector2(n * 0.5, n * 0.315), n * 0.250, hair, aa, n * 0.415)
            _circle(fig, Vector2(n * 0.400, n * 0.440), n * 0.130, hair, aa)
            _circle(fig, Vector2(n * 0.285, n * 0.450), n * 0.085, hair, aa)
            _rrect(fig, Rect2(n * 0.300, n * 0.155, n * 0.440, n * 0.100), n * 0.050, hair, aa)
        "slick":
            _circle(fig, Vector2(n * 0.5, n * 0.305), n * 0.250, hair, aa, n * 0.400)
            _rrect(fig, Rect2(n * 0.285, n * 0.235, n * 0.430, n * 0.075), 0.0, hair, aa)
            if detail >= 3:
                _rrect(fig, Rect2(n * 0.500, n * 0.150, n * 0.012, n * 0.140), 0.0, Color(0, 0, 0, 0.20), aa)
        "short":
            _circle(fig, Vector2(n * 0.5, n * 0.325), n * 0.245, hair, aa, n * 0.415)
            _circle(fig, Vector2(n * 0.310, n * 0.315), n * 0.075, hair, aa)
            _circle(fig, Vector2(n * 0.690, n * 0.315), n * 0.075, hair, aa)
            if detail >= 2:
                _circle(fig, Vector2(n * 0.400, n * 0.200), n * 0.065, hair, aa)
                _circle(fig, Vector2(n * 0.560, n * 0.175), n * 0.070, hair, aa)
                _circle(fig, Vector2(n * 0.690, n * 0.210), n * 0.060, hair, aa)
        _:
            # spiky (default)
            _circle(fig, Vector2(n * 0.5, n * 0.325), n * 0.250, hair, aa, n * 0.415)
            if detail >= 2:
                _circle(fig, Vector2(n * 0.285, n * 0.435), n * 0.078, hair, aa)
                _circle(fig, Vector2(n * 0.715, n * 0.435), n * 0.078, hair, aa)
                _circle(fig, Vector2(n * 0.345, n * 0.200), n * 0.072, hair, aa)
                _circle(fig, Vector2(n * 0.500, n * 0.145), n * 0.078, hair, aa)
                _circle(fig, Vector2(n * 0.655, n * 0.200), n * 0.072, hair, aa)
                _circle(fig, Vector2(n * 0.395, n * 0.355), n * 0.072, hair, aa)
                _circle(fig, Vector2(n * 0.605, n * 0.355), n * 0.072, hair, aa)
            if detail >= 3:
                _circle(fig, Vector2(n * 0.425, n * 0.245), n * 0.070, Color(1.0, 1.0, 1.0, 0.30), aa)


static func _draw_sword(fig: Image, n: int, aa: bool) -> void:
    var hilt := Vector2(n * 0.795, n * 0.795)
    var tip := Vector2(n * 0.930, n * 0.215)
    var steps := 22
    for i in range(steps):
        var t := float(i) / float(steps - 1)
        var pos := hilt.lerp(tip, t)
        _circle(fig, pos, n * 0.017, Color("d8dbe6"), aa)
    _rrect(fig, Rect2(n * 0.755, n * 0.795, n * 0.115, n * 0.026), 0.0, Color("34394a"), aa)
    _rrect(fig, Rect2(n * 0.780, n * 0.820, n * 0.030, n * 0.055), 0.0, Color("7a4a2a"), aa)


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
            "tagline": "Pilihan kamu · pixel detail",
            "desc": "Sprite 64 × 64 dengan outline, ditampilkan 1×–2× (64/128 px) supaya tajam. Ekspresi terbaca, hanya 16 KB per hero.",
            "recommended": true,
        },
        {
            "id": "chibi128",
            "label": "Chibi HD 128 × 128",
            "native": 128,
            "antialias": true,
            "detail": 3,
            "tagline": "Alternatif halus · non-pixel",
            "desc": "Sprite 128 × 128 anti-alias, garis halus, cocok gaya anime idle RPG modern. Ukuran tampil di HP ± 96-128 px.",
            "recommended": false,
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


static func make_texture(style_id: String, origin: String = "Default", hero_id: String = "") -> Texture2D:
    var key := "%s|%s|%s" % [style_id, origin, hero_id]
    if _cache.has(key):
        return _cache[key]
    var img := make_image(style_id, origin, hero_id)
    if img == null:
        return null
    var tex := ImageTexture.create_from_image(img)
    _cache[key] = tex
    return tex


static func make_image(style_id: String, origin: String = "Default", hero_id: String = "") -> Image:
    var style := get_style(style_id)
    var n := int(style["native"])
    var aa := bool(style["antialias"])
    var detail := int(style["detail"])
    var cfg := _hero_cfg(hero_id)
    var pal: Dictionary = _palette_for(origin, hero_id)
    var accs: Array = cfg.get("accessories", [])
    var hair_style := str(cfg.get("hair_style", "spiky"))
    var bare := bool(cfg.get("bare_chest", false))

    var fig := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)

    # ---- aura / cape behind the body --------------------------------------
    if detail >= 2 and accs.has("aura"):
        var glow: Color = pal["accent"]
        _circle(fig, Vector2(n * 0.5, n * 0.60), n * 0.44, Color(glow.r, glow.g, glow.b, 0.10), aa)
        _circle(fig, Vector2(n * 0.5, n * 0.58), n * 0.34, Color(glow.r, glow.g, glow.b, 0.12), aa)
    if detail >= 2 and accs.has("cape"):
        var cape: Color = cfg.get("cape_color", Color("f2f4fa"))
        _rrect(fig, Rect2(n * 0.19, n * 0.545, n * 0.62, n * 0.335), n * 0.055, cape, aa)
        _rrect(fig, Rect2(n * 0.30, n * 0.545, n * 0.40, n * 0.10), n * 0.03, Color(0, 0, 0, 0.10), aa)
    if detail >= 2 and accs.has("sword"):
        _draw_sword(fig, n, aa)

    # ---- legs -------------------------------------------------------------
    _rrect(fig, Rect2(n * 0.33, n * 0.82, n * 0.135, n * 0.16), n * 0.05, pal["outfit_dark"], aa)
    _rrect(fig, Rect2(n * 0.535, n * 0.82, n * 0.135, n * 0.16), n * 0.05, pal["outfit_dark"], aa)

    # ---- arms -------------------------------------------------------------
    _rrect(fig, Rect2(n * 0.195, n * 0.605, n * 0.125, n * 0.235), n * 0.055, pal["outfit"], aa)
    _rrect(fig, Rect2(n * 0.68, n * 0.605, n * 0.125, n * 0.235), n * 0.055, pal["outfit"], aa)

    # ---- torso ------------------------------------------------------------
    var torso_col: Color = pal["skin"] if bare else pal["outfit"]
    _rrect(fig, Rect2(n * 0.30, n * 0.565, n * 0.40, n * 0.285), n * 0.09, torso_col, aa)
    if bare and detail >= 2:
        # cursed-energy tattoos for shirtless fighters
        _rrect(fig, Rect2(n * 0.355, n * 0.625, n * 0.105, n * 0.018), 0.0, Color(0.11, 0.07, 0.10, 0.85), aa)
        _rrect(fig, Rect2(n * 0.535, n * 0.675, n * 0.105, n * 0.018), 0.0, Color(0.11, 0.07, 0.10, 0.85), aa)
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

    # ---- hair -------------------------------------------------------------
    _draw_hair(fig, n, pal, hair_style, aa, detail)

    # ---- head accessories (band, hat) ------------------------------------
    if detail >= 2:
        if accs.has("headband"):
            _rrect(fig, Rect2(n * 0.285, n * 0.298, n * 0.43, n * 0.055), n * 0.012, pal["accent"], aa)
            _rrect(fig, Rect2(n * 0.44, n * 0.298, n * 0.12, n * 0.055), n * 0.008, Color("c9ccd6"), aa)
        if accs.has("straw_hat"):
            var straw := Color("e8c46a")
            _rrect(fig, Rect2(n * 0.115, n * 0.262, n * 0.77, n * 0.050), n * 0.022, straw, aa)
            _rrect(fig, Rect2(n * 0.325, n * 0.135, n * 0.35, n * 0.140), n * 0.055, straw, aa)
            _rrect(fig, Rect2(n * 0.325, n * 0.238, n * 0.35, n * 0.032), n * 0.008, Color("d33b3b"), aa)

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

    # ---- face accessories (mask, blindfold, glasses, marks) --------------
    if detail >= 2:
        if accs.has("mask"):
            _rrect(fig, Rect2(n * 0.295, n * 0.492, n * 0.41, n * 0.115), n * 0.035, pal["outfit_dark"], aa)
        if accs.has("blindfold"):
            _rrect(fig, Rect2(n * 0.278, n * 0.418, n * 0.445, n * 0.085), n * 0.012, pal["outfit_dark"], aa)
            _rrect(fig, Rect2(n * 0.278, n * 0.418, n * 0.445, n * 0.020), 0.0, Color(1, 1, 1, 0.12), aa)
        if accs.has("glasses"):
            var lens := Color(0.80, 0.92, 1.0, 0.30)
            _rrect(fig, Rect2(n * 0.395, n * 0.443, n * 0.082, n * 0.046), n * 0.008, lens, aa)
            _rrect(fig, Rect2(n * 0.523, n * 0.443, n * 0.082, n * 0.046), n * 0.008, lens, aa)
            _rrect(fig, Rect2(n * 0.478, n * 0.458, n * 0.044, n * 0.014), 0.0, Color(0.15, 0.15, 0.2, 0.9), aa)
        if accs.has("face_marks"):
            _rrect(fig, Rect2(n * 0.398, n * 0.503, n * 0.030, n * 0.055), 0.0, Color(0.10, 0.06, 0.08, 0.8), aa)
            _rrect(fig, Rect2(n * 0.572, n * 0.503, n * 0.030, n * 0.055), 0.0, Color(0.10, 0.06, 0.08, 0.8), aa)
        if accs.has("cyborg"):
            _rrect(fig, Rect2(n * 0.212, n * 0.635, n * 0.018, n * 0.175), 0.0, pal["accent"], aa)
            _rrect(fig, Rect2(n * 0.768, n * 0.635, n * 0.018, n * 0.175), 0.0, pal["accent"], aa)
        if accs.has("high_collar"):
            _rrect(fig, Rect2(n * 0.300, n * 0.540, n * 0.135, n * 0.105), n * 0.030, pal["outfit_dark"], aa)
            _rrect(fig, Rect2(n * 0.565, n * 0.540, n * 0.135, n * 0.105), n * 0.030, pal["outfit_dark"], aa)

    # ---- outline ----------------------------------------------------------
    if detail >= 2:
        _outline(fig, Color(0.03, 0.04, 0.09, 0.9))

    # ---- composite (aura goes behind the figure) --------------------------
    var img := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)
    if detail >= 4 and not accs.has("aura"):
        var accent: Color = pal["accent"]
        var aura := Color(accent.r, accent.g, accent.b, 0.10)
        _circle(img, Vector2(n * 0.5, n * 0.60), n * 0.47, aura, aa)
        _circle(img, Vector2(n * 0.5, n * 0.60), n * 0.40, aura, aa)

    img.blend_rect(fig, Rect2i(Vector2i.ZERO, Vector2i(n, n)), Vector2i.ZERO)
    return img


static func make_anim_texture(
    style_id: String, origin: String, anim: String, frame: int, hero_id: String = ""
) -> Texture2D:
    var key := "%s|%s|%s|%d|%s" % [style_id, origin, anim, frame, hero_id]
    if _cache.has(key):
        return _cache[key]
    var img := make_anim_image(style_id, origin, anim, frame, hero_id)
    if img == null:
        return null
    var tex := ImageTexture.create_from_image(img)
    _cache[key] = tex
    return tex


static func make_anim_image(
    style_id: String, origin: String, anim: String, frame: int, hero_id: String = ""
) -> Image:
    var base := make_image(style_id, origin, hero_id)
    if base == null:
        return null
    var style := get_style(style_id)
    var aa := bool(style["antialias"])
    var accent: Color = _palette_for(origin, hero_id)["accent"]
    var count := int(ANIMS.get(anim, ANIMS["idle"])["frames"])
    frame = clampi(frame, 0, count - 1)

    match anim:
        "attack":
            return _attack_frame(base, frame, aa, accent)
        "hurt":
            return _hurt_frame(base, frame, aa)
        "victory":
            return _victory_frame(base, frame, aa, accent)
        _:
            return _idle_frame(base, frame)


static func _step_for(n: int) -> float:
    # Pixel sizes differ (16, 32, 64, 128, 256); keep motion proportional.
    return maxf(1.0, roundf(float(n) / 64.0))


static func _blank(n: int) -> Image:
    return Image.create_empty(n, n, false, Image.FORMAT_RGBA8)


static func _shift(img: Image, dx: int, dy: int) -> Image:
    var n := img.get_width()
    var out := _blank(n)
    var w := n - absi(dx)
    var h := n - absi(dy)
    if w <= 0 or h <= 0:
        return out
    var src := Rect2i(maxi(0, -dx), maxi(0, -dy), w, h)
    var dst := Vector2i(maxi(0, dx), maxi(0, dy))
    out.blit_rect(img.get_region(src), Rect2i(Vector2i.ZERO, Vector2i(w, h)), dst)
    return out


static func _flash(img: Image, amount: float) -> Image:
    var out: Image = img.duplicate()
    for y in range(out.get_height()):
        for x in range(out.get_width()):
            var c := out.get_pixel(x, y)
            if c.a <= 0.01:
                continue
            out.set_pixel(
                x,
                y,
                Color(
                    lerpf(c.r, 1.0, amount),
                    lerpf(c.g, 1.0, amount),
                    lerpf(c.b, 1.0, amount),
                    c.a
                )
            )
    return out


static func _tint(img: Image, tint: Color, amount: float) -> Image:
    var out: Image = img.duplicate()
    for y in range(out.get_height()):
        for x in range(out.get_width()):
            var c := out.get_pixel(x, y)
            if c.a <= 0.01:
                continue
            out.set_pixel(
                x,
                y,
                Color(lerpf(c.r, tint.r, amount), lerpf(c.g, tint.g, amount), lerpf(c.b, tint.b, amount), c.a)
            )
    return out


static func _idle_frame(base: Image, frame: int) -> Image:
    var n := base.get_width()
    var step := _step_for(n)
    var bob := [0.0, -1.0, -1.0, 0.0]
    var dy := int(bob[frame % bob.size()] * step)
    return _shift(base, 0, dy)


static func _attack_frame(base: Image, frame: int, aa: bool, accent: Color) -> Image:
    var n := base.get_width()
    var step := _step_for(n)
    # wind-up -> lunge -> strike -> recover
    var offsets := [
        Vector2(-1, 0),
        Vector2(-2, 0),
        Vector2(3, -1),
        Vector2(5, -1),
        Vector2(2, 0),
        Vector2(0, 0),
    ]
    var off: Vector2 = offsets[frame]
    var out := _shift(base, int(off.x * step), int(off.y * step))

    if frame == 1:
        out = _flash(out, 0.20)
    if frame >= 2 and frame <= 4:
        # motion trails behind the fighter
        for i in range(3):
            var y := n * (0.42 + i * 0.09)
            _rrect(
                out,
                Rect2(n * 0.03, y, n * 0.20, maxf(1.0, n * 0.018)),
                0.0,
                Color(1.0, 1.0, 1.0, 0.42),
                aa
            )
        # slash swoosh grows then fades
        var progress: float = [0.45, 1.0, 0.7][frame - 2]
        _slash(out, progress, accent, aa)
    return out


static func _slash(img: Image, progress: float, accent: Color, aa: bool) -> void:
    var n := img.get_width()
    var steps := 26
    var center := Vector2(n * 0.55, n * 0.45)
    var radius := n * 0.42
    for i in range(steps):
        var u := float(i) / float(steps - 1)
        if u > progress:
            break
        var angle := lerpf(-1.25, 0.85, u)
        var pos := center + Vector2(cos(angle), sin(angle)) * radius
        var r := n * 0.046 * (1.0 - 0.35 * u)
        var col := accent.lerp(Color(1, 1, 1), 0.6)
        col.a = 0.9 * (1.0 - 0.3 * u)
        _circle(img, pos, r, col, aa)
        _circle(img, pos, r * 0.45, Color(1, 1, 1, 0.95), aa)


static func _hurt_frame(base: Image, frame: int, aa: bool) -> Image:
    var n := base.get_width()
    var step := _step_for(n)
    var out := base
    if frame == 0:
        out = _flash(base, 0.28)
    elif frame == 1:
        out = _shift(base, int(-2 * step), 0)
    else:
        out = _shift(base, int(step), 0)
    return _tint(out, Color(1.0, 0.42, 0.42), 0.28)


static func _victory_frame(base: Image, frame: int, aa: bool, accent: Color) -> Image:
    var n := base.get_width()
    var step := _step_for(n)
    var hops := [0.0, -2.0, -3.0, -1.0]
    var out := _shift(base, 0, int(hops[frame] * step))

    var sparkles := [
        [Vector2(0.16, 0.26), 0.055],
        [Vector2(0.84, 0.36), 0.060],
        [Vector2(0.24, 0.74), 0.045],
        [Vector2(0.78, 0.70), 0.050],
    ]
    for i in range(mini(frame + 1, sparkles.size())):
        var pos: Vector2 = sparkles[i][0] * n
        var r: float = sparkles[i][1] * n
        _circle(out, pos, r, Color(accent.r, accent.g, accent.b, 0.55), aa)
        _circle(out, pos, r * 0.65, Color(1.0, 0.98, 0.82, 0.85), aa)
        _circle(out, pos, r * 0.3, Color(1, 1, 1, 0.95), aa)
    return out


static func _palette_for(origin: String, hero_id: String = "") -> Dictionary:
    var base: Dictionary = _palettes[origin] if _palettes.has(origin) else _palettes["Default"]
    var out: Dictionary = base.duplicate()
    var cfg := _hero_cfg(hero_id)
    for field in ["hair", "skin", "outfit", "outfit_dark", "accent", "eye"]:
        if cfg.has(field):
            out[field] = cfg[field]
    return out


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
