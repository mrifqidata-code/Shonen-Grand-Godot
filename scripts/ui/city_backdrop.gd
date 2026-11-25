# scripts/ui/city_backdrop.gd
# Procedural fantasy backdrop for the City home screen: night sky gradient,
# moon glow and castle silhouettes. No art files needed; a real illustration can
# be dropped at res://assets/sprites/ui/city_bg.png and it will be used instead.
extends Control
class_name CityBackdrop


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	var custom := _custom_texture()
	if custom != null:
		var tw := float(custom.get_width())
		var th := float(custom.get_height())
		var scale := maxf(w / tw, h / th)
		var dw := tw * scale
		var dh := th * scale
		draw_texture_rect(custom, Rect2((w - dw) * 0.5, (h - dh) * 0.5, dw, dh), false)
	else:
		_sky(w, h)
		_moon(w, h)
		_castle(w, h)

	# Bottom fade so the nav bar and buttons stay readable.
	for i in range(18):
		var a := 0.045 * float(i + 1)
		draw_rect(Rect2(0, h - 40.0 - i * 10.0, w, 40.0 + i * 10.0), Color(0.02, 0.02, 0.06, a))


func _custom_texture() -> Texture2D:
	var path := "res://assets/sprites/ui/city_bg.png"
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _sky(w: float, h: float) -> void:
	var top := Color("2a2350")
	var mid := Color("18203f")
	var bottom := Color("0a0c18")
	var bands := 64
	for i in range(bands):
		var t := float(i) / float(bands)
		var c: Color
		if t < 0.5:
			c = top.lerp(mid, t * 2.0)
		else:
			c = mid.lerp(bottom, (t - 0.5) * 2.0)
		draw_rect(Rect2(0, h * t, w, h / float(bands) + 1.0), c)


func _moon(w: float, h: float) -> void:
	var centre := Vector2(w * 0.5, h * 0.26)
	draw_circle(centre, 190.0, Color(0.45, 0.55, 0.95, 0.07))
	draw_circle(centre, 130.0, Color(0.55, 0.65, 1.0, 0.10))
	draw_circle(centre, 78.0, Color(0.72, 0.80, 1.0, 0.18))


func _castle(w: float, h: float) -> void:
	var dark := Color(0.05, 0.06, 0.13, 0.96)
	var mid := Color(0.09, 0.10, 0.20, 0.92)
	var base_y := h * 0.90
	# towers: [center_x, width, height]
	var towers := [
		[0.08, 0.14, 0.11],
		[0.24, 0.10, 0.17],
		[0.38, 0.08, 0.10],
		[0.62, 0.08, 0.10],
		[0.76, 0.10, 0.17],
		[0.92, 0.14, 0.11],
	]
	for t in towers:
		var cx: float = float(t[0]) * w
		var tw: float = float(t[1]) * w
		var th: float = float(t[2]) * h
		draw_rect(Rect2(cx - tw * 0.5, base_y - th, tw, th), mid)
		# spire
		draw_colored_polygon(
			PackedVector2Array(
				[
					Vector2(cx, base_y - th - tw * 0.55),
					Vector2(cx - tw * 0.55, base_y - th),
					Vector2(cx + tw * 0.55, base_y - th),
				]
			),
			mid
		)
	# central keep
	var cw := w * 0.30
	var ch := h * 0.20
	draw_rect(Rect2(w * 0.5 - cw * 0.5, base_y - ch, cw, ch), dark)
	draw_colored_polygon(
		PackedVector2Array(
			[
				Vector2(w * 0.5, base_y - ch - cw * 0.42),
				Vector2(w * 0.5 - cw * 0.58, base_y - ch),
				Vector2(w * 0.5 + cw * 0.58, base_y - ch),
			]
		),
		dark
	)
	# lit windows
	var win := Color(0.95, 0.82, 0.45, 0.55)
	for i in range(5):
		var wx := w * 0.5 - cw * 0.30 + float(i) * (cw * 0.15)
		draw_rect(Rect2(wx, base_y - ch * 0.55, 8.0, 12.0), win)
	# ground platform glow
	draw_circle(Vector2(w * 0.5, base_y + h * 0.05), w * 0.45, Color(0.35, 0.5, 0.95, 0.06))
