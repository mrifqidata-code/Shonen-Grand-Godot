# scripts/ui/cutin_backdrop.gd
# Full-screen backdrop used behind the ultimate cut-in. Prefers a real Canva
# illustration at res://assets/sprites/heroes/<hero_id>/cutin.png (or the
# per-anime fallback) and otherwise paints a procedural one from the same
# hero palette: radial glow, diagonal speed lines and the HD portrait.
extends Control
class_name CutinBackdrop

const Factory := preload("res://scripts/services/character_sprite_factory.gd")

@export var hero_id: String = ""
@export var anime_origin: String = "Naruto"
@export var enemy: bool = false
@export var accent: Color = Color("f7b733")

var _custom: Texture2D = null
var _custom_checked := false
var _procedural: Texture2D = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _load_custom() -> void:
	if _custom_checked:
		return
	_custom_checked = true
	var candidates := []
	if not hero_id.is_empty():
		candidates.append("res://assets/sprites/heroes/%s/cutin.png" % hero_id)
	candidates.append("res://assets/sprites/heroes/%s/cutin.png" % anime_origin)
	for path in candidates:
		if ResourceLoader.exists(path):
			var tex := load(path) as Texture2D
			if tex != null:
				_custom = tex
				return


func _procedural_texture() -> Texture2D:
	if _procedural != null:
		return _procedural
	var img := Factory.make_image("hd256", anime_origin, hero_id)
	if img == null:
		return null
	_procedural = ImageTexture.create_from_image(img)
	return _procedural


func _draw() -> void:
	_load_custom()
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	# Dark base so the illustration never blows out the UI on top.
	draw_rect(Rect2(0, 0, w, h), Color(0.02, 0.03, 0.09, 1.0))

	if _custom != null:
		var tw := float(_custom.get_width())
		var th := float(_custom.get_height())
		var scale := maxf(w / tw, h / th)
		var dw := tw * scale
		var dh := th * scale
		var dx := (w - dw) * 0.5
		var dy := (h - dh) * 0.5
		draw_texture_rect(_custom, Rect2(dx, dy, dw, dh), false)
	else:
		# Radial glow in the hero accent colour.
		var center := Vector2(w * 0.5, h * 0.42)
		for i in range(7):
			var r := (i + 1) * 110.0
			var a := 0.20 - float(i) * 0.022
			draw_circle(center, r, Color(accent.r, accent.g, accent.b, a))

		# HD portrait, enlarged and centred.
		var tex := _procedural_texture()
		if tex != null:
			var s := minf(w, h) * 0.55
			var rect := Rect2((w - s) * 0.5, (h - s) * 0.5 - h * 0.06, s, s)
			draw_texture_rect(tex, rect, false)

		# Diagonal speed lines.
		for i in range(16):
			var y := float(i) * (h / 16.0)
			draw_line(
				Vector2(0.0, y),
				Vector2(w, y + 90.0),
				Color(accent.r, accent.g, accent.b, 0.10),
				1.0
			)

	# Vignette: darken the edges so the name stays readable.
	for i in range(10):
		var a := 0.05 * float(i + 1)
		draw_rect(Rect2(0, 0, w, 40.0 + i * 8.0), Color(0, 0, 0, a))
		draw_rect(Rect2(0, h - 40.0 - i * 8.0, w, 40.0 + i * 8.0), Color(0, 0, 0, a))
		draw_rect(Rect2(0, 0, 36.0 + i * 6.0, h), Color(0, 0, 0, a * 0.6))
		draw_rect(Rect2(w - 36.0 - i * 6.0, 0, 36.0 + i * 6.0, h), Color(0, 0, 0, a * 0.6))
