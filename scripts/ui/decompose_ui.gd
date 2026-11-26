# scripts/ui/decompose_ui.gd
# Decompose: convert spare (non-team) heroes into hero shards, and materials into
# shards, mirroring Twilight's DecomposeCfg.
extends Control

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")

@onready var list: VBoxContainer = $VBox/Scroll/List
@onready var status_label: Label = $VBox/StatusLabel


func _ready() -> void:
	$VBox/HeaderRow/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	_build()


func _build() -> void:
	for child in list.get_children():
		child.queue_free()

	# Heroes by rarity (only those not in the active team).
	for rarity in ["R", "SR", "SSR", "SSR+", "UR", "EX"]:
		var candidates := _heroes_of_rarity(rarity)
		if candidates.is_empty():
			continue
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 10))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var title := Label.new()
		title.text = "Decompose %s  ×%d" % [rarity, candidates.size()]
		title.add_theme_font_size_override("font_size", 15)
		title.add_theme_color_override("font_color", GOLD)
		info.add_child(title)
		var sub := Label.new()
		var yield_per := int(GameConfig.DECOMPOSE_SHARDS.get(rarity, 0))
		sub.text = "→ %d hero shard tiap hero (total %d)" % [yield_per, yield_per * candidates.size()]
		sub.add_theme_font_size_override("font_size", 11)
		sub.add_theme_color_override("font_color", Color(0.66, 0.69, 0.78))
		info.add_child(sub)

		var btn := Button.new()
		btn.text = "Decompose"
		btn.custom_minimum_size = Vector2(110, 40)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.pressed.connect(_decompose_rarity.bind(rarity))
		row.add_child(btn)
		list.add_child(card)

	# Materials -> shards.
	for key in ["courage_essence", "soul_crystal"]:
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 10))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var title := Label.new()
		var icon := "💫" if key == "courage_essence" else "🔮"
		title.text = "Convert %s" % key.replace("_", " ").capitalize()
		title.add_theme_font_size_override("font_size", 15)
		title.add_theme_color_override("font_color", GOLD)
		info.add_child(title)
		var sub := Label.new()
		sub.text = "%s %d dimiliki · 10 material → 1 shard" % [icon, int(GameManager.progress.get(key, 0))]
		sub.add_theme_font_size_override("font_size", 11)
		sub.add_theme_color_override("font_color", Color(0.66, 0.69, 0.78))
		info.add_child(sub)
		var btn := Button.new()
		btn.text = "Convert 10"
		btn.custom_minimum_size = Vector2(110, 40)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.pressed.connect(_convert.bind(key))
		row.add_child(btn)
		list.add_child(card)

	if list.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "Tidak ada yang bisa di-decompose."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		list.add_child(empty)


func _heroes_of_rarity(rarity: String) -> Array:
	var out := []
	for hero in GameManager.heroes:
		if str(hero.get("rarity", "")) != rarity:
			continue
		if _in_team(str(hero.get("id", ""))):
			continue
		out.append(hero)
	return out


func _in_team(hero_id: String) -> bool:
	for t in GameManager.teams:
		for s in t.get("slots", []):
			if str(s.get("hero_id", "")) == hero_id:
				return true
	return false


func _decompose_rarity(rarity: String) -> void:
	var n := GameManager.decompose_heroes(rarity)
	status_label.text = "✅ %d hero %s → %d shard" % [n, rarity, int(GameConfig.DECOMPOSE_SHARDS.get(rarity, 0)) * n]
	status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
	_build()


func _convert(key: String) -> void:
	if GameManager.convert_material(key, 10):
		status_label.text = "✅ 10 %s → 1 shard" % key
		status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
	else:
		status_label.text = "❌ Tidak cukup material."
		status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
	_build()


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(8)
	return sb
