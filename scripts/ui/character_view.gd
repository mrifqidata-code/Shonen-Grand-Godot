# scripts/ui/character_view.gd
# Reusable character avatar.
#
# Draws a character preview using the currently selected display style.
# If real art exists at res://assets/sprites/heroes/<origin>/<style_id>.png
# it is used instead of the procedural placeholder, so swapping in Canva art
# later needs no code change.
@tool
class_name CharacterView
extends Control

const Factory := preload("res://scripts/services/character_sprite_factory.gd")

@export var style_id: String = "chibi128":
    set(value):
        if style_id == value and _texture != null:
            return
        style_id = value
        _texture = null
        _apply_filter()
        queue_redraw()

@export var anime_origin: String = "Naruto":
    set(value):
        if anime_origin == value and _texture != null:
            return
        anime_origin = value
        _texture = null
        queue_redraw()

var _texture: Texture2D = null


func _ready() -> void:
    if custom_minimum_size == Vector2.ZERO:
        custom_minimum_size = Vector2(64, 64)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _apply_filter()
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


func _resolve_texture() -> Texture2D:
    if _texture != null:
        return _texture
    var custom_path := "res://assets/sprites/heroes/%s/%s.png" % [anime_origin, style_id]
    if ResourceLoader.exists(custom_path):
        _texture = load(custom_path)
        return _texture
    _texture = Factory.make_texture(style_id, anime_origin)
    return _texture


func _draw() -> void:
    var tex := _resolve_texture()
    if tex == null:
        return
    var side := minf(size.x, size.y)
    if side <= 0.0:
        return
    var rect := Rect2((size - Vector2(side, side)) * 0.5, Vector2(side, side))
    draw_texture_rect(tex, rect, false)
