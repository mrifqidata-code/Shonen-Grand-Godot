# scripts/ui/character_view.gd
# Reusable character avatar with optional idle/attack/hurt/victory animation.
#
# Draws a character preview using the currently selected display style.
# If real art exists at res://assets/sprites/heroes/<origin>/<style_id>.png
# it is used instead of the procedural placeholder, so swapping in Canva art
# later needs no code change (custom art is shown as a single still frame).
@tool
class_name CharacterView
extends Control

const Factory := preload("res://scripts/services/character_sprite_factory.gd")

@export var style_id: String = "px64":
    set(value):
        if style_id == value:
            return
        style_id = value
        _custom_texture = null
        _custom_checked = false
        _apply_filter()
        queue_redraw()

@export var anime_origin: String = "Naruto":
    set(value):
        if anime_origin == value:
            return
        anime_origin = value
        _custom_texture = null
        _custom_checked = false
        queue_redraw()

## Optional template id (e.g. "naruto_uzumaki") for per-hero Canva art.
## Falls back to per-origin art, then to the procedural placeholder.
@export var hero_id: String = "":
    set(value):
        if hero_id == value:
            return
        hero_id = value
        _custom_texture = null
        _custom_checked = false
        queue_redraw()

## Loop the idle clip. Leave off for static previews (cards, lists).
@export var animate_idle: bool = false:
    set(value):
        animate_idle = value
        if is_inside_tree():
            set_process(value or _anim != "idle")

## Enemies face left, the player team faces right.
@export var flip_h: bool = false:
    set(value):
        flip_h = value
        queue_redraw()

var _custom_texture: Texture2D = null
var _custom_checked := false
var _anim := "idle"
var _anim_elapsed := 0.0


func _ready() -> void:
    if custom_minimum_size == Vector2.ZERO:
        custom_minimum_size = Vector2(64, 64)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _apply_filter()
    set_process(animate_idle)
    queue_redraw()


func _process(delta: float) -> void:
    var def: Dictionary = Factory.ANIMS.get(_anim, Factory.ANIMS["idle"])
    _anim_elapsed += delta
    var total := float(def["frames"]) / float(def["fps"])
    if not bool(def["loop"]) and _anim_elapsed >= total:
        _anim = "idle"
        _anim_elapsed = 0.0
        if not animate_idle:
            set_process(false)
    queue_redraw()


func _apply_filter() -> void:
    texture_filter = (
        CanvasItem.TEXTURE_FILTER_NEAREST
        if Factory.is_nearest(style_id)
        else CanvasItem.TEXTURE_FILTER_LINEAR
    )


func set_character(origin: String, style: String = "") -> void:
    anime_origin = origin
    if style != "":
        style_id = style


## One-shot clip: "attack", "hurt" or "victory". Returns to idle automatically.
func play(anim: String) -> void:
    if not Factory.ANIMS.has(anim):
        return
    _anim = anim
    _anim_elapsed = 0.0
    set_process(true)
    queue_redraw()


func current_anim() -> String:
    return _anim


func _frame_index() -> int:
    var def: Dictionary = Factory.ANIMS.get(_anim, Factory.ANIMS["idle"])
    var frames := int(def["frames"])
    var idx := int(_anim_elapsed * float(def["fps"]))
    if bool(def["loop"]):
        return idx % frames
    return mini(idx, frames - 1)


func _resolve_texture() -> Texture2D:
    if not _custom_checked:
        _custom_checked = true
        _custom_texture = _load_custom_art()
        if _custom_texture != null:
            _apply_custom_filter(_custom_texture)
    if _custom_texture != null:
        return _custom_texture
    return Factory.make_anim_texture(style_id, anime_origin, _anim, _frame_index(), hero_id)


## Custom art lookup: per-hero first, then per-anime origin.
func _load_custom_art() -> Texture2D:
    var candidates := []
    if not hero_id.is_empty():
        candidates.append("res://assets/sprites/heroes/%s/%s.png" % [hero_id, style_id])
    candidates.append("res://assets/sprites/heroes/%s/%s.png" % [anime_origin, style_id])
    for path in candidates:
        if ResourceLoader.exists(path):
            var tex := load(path) as Texture2D
            if tex != null:
                return tex
    return null


func _apply_custom_filter(tex: Texture2D) -> void:
    # Nearest only while the art is at (or below) native pixel size; larger
    # illustrations are downscaled smoothly to fit the box.
    if Factory.is_nearest(style_id) and tex.get_width() <= Factory.native_size(style_id):
        texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    else:
        texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func _draw() -> void:
    var tex := _resolve_texture()
    if tex == null:
        return
    var side := minf(size.x, size.y)
    if side <= 0.0:
        return
    var tex_size := tex.get_size()
    if tex_size.x <= 0.0:
        return

    # Pixel styles must scale by whole numbers, otherwise the art looks blurry
    # or shimmers when it moves. Oversized custom art is fitted instead so it
    # never overflows the box.
    var native := Factory.native_size(style_id)
    var is_custom := _custom_texture != null
    var render_scale := side / tex_size.x
    if Factory.is_nearest(style_id) and (not is_custom or tex_size.x <= native):
        render_scale = maxf(1.0, floorf(render_scale))

    var draw_size := tex_size * render_scale
    var rect := Rect2((size - draw_size) * 0.5, draw_size)
    if flip_h:
        draw_set_transform(Vector2(size.x, 0.0), 0.0, Vector2(-1.0, 1.0))
    draw_texture_rect(tex, rect, false)
    if flip_h:
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
