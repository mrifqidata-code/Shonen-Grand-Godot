# scripts/ui/main_ui.gd
# City home screen, laid out like a mobile idle-RPG hub: top resource bar,
# floating feature buttons, side rails, a central campaign stage and a bottom
# nav. Every destination maps to an existing scene of the game.
extends Control

const CityBackdropScript := preload("res://scripts/ui/city_backdrop.gd")
const CharacterViewScript := preload("res://scripts/ui/character_view.gd")

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")
const PANEL_BG := Color(0.08, 0.08, 0.15, 0.88)

const SCENES := {
	"summon": "res://scenes/ui/summon.tscn",
	"heroes": "res://scenes/ui/heroes.tscn",
	"team": "res://scenes/ui/team.tscn",
	"battle": "res://scenes/ui/battle.tscn",
	"bag": "res://scenes/ui/inventory.tscn",
	"store": "res://scenes/ui/store.tscn",
	"pve": "res://scenes/ui/pve.tscn",
	"gear": "res://scenes/ui/gear.tscn",
	"submenu": "res://scenes/ui/submenu.tscn",
	"submenu": "res://scenes/ui/submenu.tscn",
	"decompose": "res://scenes/ui/decompose.tscn",
	"market": "res://scenes/ui/market.tscn",
	"style": "res://scenes/ui/character_style.tscn",
	"canva": "res://scenes/ui/canva_generator.tscn",
	"home": "res://scenes/main.tscn",
}

var _power_label: Label
var _gold_label: Label
var _dia_label: Label
var _level_label: Label
var _idle_label: Label


func _ready() -> void:
	await get_tree().process_frame
	_build()
	_refresh()


func _go(key: String) -> void:
	if key.begins_with("menu:"):
		GameManager.pending_menu = key.substr(5)
		SceneManager.change_scene(SCENES["submenu"])
		return
	SceneManager.change_scene(SCENES.get(key, SCENES["home"]))


# ---------------------------------------------------------------- build -----
func _build() -> void:
	var w := size.x
	var h := size.y

	var backdrop := CityBackdropScript.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	_build_top_bar(w)
	_build_feature_grid(w, h)
	_build_stage(w, h)
	_build_idle_card(w, h)
	_build_team_row(w, h)
	_build_rails(w, h)
	_build_bottom_nav(w, h)


func _build_top_bar(w: float) -> void:
	var bar := PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.offset_left = 8.0
	bar.offset_right = -8.0
	bar.offset_top = 8.0
	bar.offset_bottom = 116.0
	bar.add_theme_stylebox_override("panel", _panel_style(PANEL_BG, GOLD_DIM, 2, 10))
	add_child(bar)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	bar.add_child(row)

	# Avatar + level
	var avatar_box := VBoxContainer.new()
	avatar_box.add_theme_constant_override("separation", 0)
	row.add_child(avatar_box)
	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(58, 58)
	avatar.add_theme_stylebox_override("panel", _panel_style(Color(0.12, 0.11, 0.22), GOLD, 2, 4))
	avatar_box.add_child(avatar)
	var avatar_icon := Label.new()
	avatar_icon.text = "⚔️"
	avatar_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar_icon.add_theme_font_size_override("font_size", 26)
	avatar.add_child(avatar_icon)
	_level_label = Label.new()
	_level_label.text = "Lv.1"
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level_label.add_theme_font_size_override("font_size", 12)
	avatar_box.add_child(_level_label)

	# Name, stamina, power
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)
	var name_label := Label.new()
	name_label.text = "Shonen Grand"
	name_label.add_theme_font_size_override("font_size", 15)
	info.add_child(name_label)
	var stamina := ProgressBar.new()
	stamina.min_value = 0
	stamina.max_value = 100
	stamina.value = 78
	stamina.show_percentage = false
	stamina.custom_minimum_size = Vector2(0, 12)
	stamina.add_theme_stylebox_override("background", _panel_style(Color(0.06, 0.08, 0.14), Color(0, 0, 0, 0), 0, 0))
	stamina.add_theme_stylebox_override("fill", _panel_style(Color("57d97a"), Color(0, 0, 0, 0), 0, 0))
	info.add_child(stamina)
	_power_label = Label.new()
	_power_label.text = "⚔️ 0"
	_power_label.add_theme_font_size_override("font_size", 13)
	_power_label.add_theme_color_override("font_color", GOLD)
	info.add_child(_power_label)

	# Currencies
	var currency := VBoxContainer.new()
	currency.add_theme_constant_override("separation", 4)
	row.add_child(currency)
	var dia_row := _currency_pill("💎", "0")
	_dia_label = dia_row.find_child("Value", true, false)
	currency.add_child(dia_row)
	var gold_row := _currency_pill("💰", "0")
	_gold_label = gold_row.find_child("Value", true, false)
	currency.add_child(gold_row)


func _currency_pill(icon: String, value: String) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = Vector2(150, 0)
	pill.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.07, 0.13, 0.95), GOLD_DIM, 1, 6))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 4)
	pill.add_child(hb)
	var icon_label := Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 14)
	hb.add_child(icon_label)
	var value_label := Label.new()
	value_label.name = "Value"
	value_label.text = value
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.add_theme_font_size_override("font_size", 13)
	hb.add_child(value_label)
	var plus := Button.new()
	plus.text = "+"
	plus.custom_minimum_size = Vector2(26, 24)
	plus.pressed.connect(func(): _go("summon"))
	hb.add_child(plus)
	return pill


func _build_feature_grid(w: float, h: float) -> void:
	var entries := [
		["🎰", "Summon", "summon"],
		["⚔️", "Campaign", "battle"],
		["👥", "Hero", "heroes"],
		["🛡️", "Team", "team"],
		["📦", "Bag", "bag"],
		["🛒", "Market", "market"],
		["🗼", "Tower", "pve"],
		["🎭", "Style", "style"],
		["🎨", "Canva", "canva"],
		["🏆", "Ranking", "menu:ranking"],
		["📅", "Dailies", "menu:dailies"],
	]
	var cols := 5
	var cell_w := w / float(cols)
	var top := 128.0
	var cell_h := 104.0
	for i in range(entries.size()):
		var col := i % cols
		var row := i / cols
		var cell := _feature_button(str(entries[i][0]), str(entries[i][1]), str(entries[i][2]))
		cell.size = Vector2(cell_w - 8.0, cell_h - 8.0)
		cell.position = Vector2(col * cell_w + 4.0, top + row * cell_h)
		add_child(cell)


func _feature_button(icon: String, caption: String, dest: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	var btn := Button.new()
	btn.text = icon
	btn.custom_minimum_size = Vector2(64, 58)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_stylebox_override("normal", _panel_style(Color(0.10, 0.09, 0.18, 0.92), GOLD, 2, 10))
	btn.add_theme_stylebox_override("hover", _panel_style(Color(0.16, 0.14, 0.26, 0.96), GOLD, 2, 10))
	btn.add_theme_stylebox_override("pressed", _panel_style(Color(0.07, 0.06, 0.12, 1.0), GOLD, 2, 10))
	btn.pressed.connect(func(): _go(dest))
	box.add_child(btn)
	var label := Label.new()
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	box.add_child(label)
	return box


func _build_stage(w: float, h: float) -> void:
	var stage := VBoxContainer.new()
	stage.add_theme_constant_override("separation", 8)
	stage.position = Vector2(w * 0.20, h * 0.46)
	stage.size = Vector2(w * 0.60, h * 0.24)
	add_child(stage)

	var title := Label.new()
	title.text = "⚔️ CAMPAIGN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", GOLD)
	stage.add_child(title)

	var cta := Button.new()
	cta.text = "Masuk Campaign"
	cta.custom_minimum_size = Vector2(0, 52)
	cta.add_theme_font_size_override("font_size", 17)
	cta.add_theme_stylebox_override("normal", _panel_style(Color(0.18, 0.12, 0.06, 0.95), GOLD, 2, 10))
	cta.add_theme_stylebox_override("hover", _panel_style(Color(0.26, 0.18, 0.08, 0.98), GOLD, 2, 10))
	cta.pressed.connect(func(): _go("battle"))
	stage.add_child(cta)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	stage.add_child(row)
	for entry in [["🌙", "Summoning\nCircle", "summon"], ["🔮", "Evolution\nTemple", "heroes"], ["🛒", "Twilight\nShop", "store"]]:
		var b := Button.new()
		b.text = "%s\n%s" % [entry[0], entry[1]]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 62)
		b.add_theme_font_size_override("font_size", 12)
		b.add_theme_stylebox_override("normal", _panel_style(Color(0.09, 0.09, 0.17, 0.92), GOLD_DIM, 2, 8))
		b.add_theme_stylebox_override("hover", _panel_style(Color(0.15, 0.14, 0.24, 0.96), GOLD, 2, 8))
		b.pressed.connect(func(): _go(str(entry[2])))
		row.add_child(b)


func _build_idle_card(w: float, h: float) -> void:
	var card := PanelContainer.new()
	card.position = Vector2(w * 0.10, h * 0.66)
	card.size = Vector2(w * 0.80, 104)
	card.add_theme_stylebox_override("panel", _panel_style(PANEL_BG, GOLD_DIM, 2, 10))
	add_child(card)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)

	var title := Label.new()
	title.text = "💤 Idle Reward"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", GOLD)
	box.add_child(title)

	_idle_label = Label.new()
	_idle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_idle_label.add_theme_font_size_override("font_size", 12)
	box.add_child(_idle_label)

	var claim := Button.new()
	claim.text = "Klaim Reward"
	claim.custom_minimum_size = Vector2(0, 40)
	claim.pressed.connect(func(): _on_claim_idle())
	box.add_child(claim)


func _on_claim_idle() -> void:
	GameManager.collect_idle_rewards()
	GameManager.save_game()
	_refresh()


func _build_team_row(w: float, h: float) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 4)
	row.position = Vector2(0.0, h * 0.79)
	row.size = Vector2(w, 84)
	add_child(row)
	var heroes := GameManager.get_player_heroes()
	if heroes.is_empty():
		return
	for hero in heroes.slice(0, 6):
		var view := CharacterViewScript.new()
		view.custom_minimum_size = Vector2(56, 56)
		view.style_id = GameManager.get_character_style()
		view.anime_origin = str(hero.get("anime_origin", "Default"))
		view.hero_id = str(hero.get("template_id", ""))
		row.add_child(view)


func _build_rails(w: float, h: float) -> void:
	var left := [
		["📖", "Guide", "style"],
		["🏆", "Ranking", "menu:ranking"],
		["👥", "Friends", "menu:friends"],
		["✉️", "Mail", "menu:mail"],
	]
	var right := [
		["👁", "Preview", "style"],
		["📜", "Quest", "pve"],
		["🎒", "Bag", "bag"],
		["📅", "Dailies", "menu:dailies"],
	]
	_rail(left, 4.0, h * 0.40)
	_rail(right, w - 4.0 - 78.0, h * 0.40)


func _rail(entries: Array, x: float, y: float) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.position = Vector2(x, y)
	box.size = Vector2(78, 300)
	add_child(box)
	for entry in entries:
		var b := Button.new()
		b.text = "%s\n%s" % [entry[0], entry[1]]
		b.custom_minimum_size = Vector2(74, 52)
		b.add_theme_font_size_override("font_size", 11)
		b.add_theme_stylebox_override("normal", _panel_style(Color(0.08, 0.08, 0.15, 0.82), GOLD_DIM, 1, 6))
		b.add_theme_stylebox_override("hover", _panel_style(Color(0.15, 0.14, 0.24, 0.95), GOLD, 1, 6))
		b.pressed.connect(func(): _go(str(entry[2])))
		box.add_child(b)


func _build_bottom_nav(w: float, h: float) -> void:
	var nav := PanelContainer.new()
	nav.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	nav.offset_left = 6.0
	nav.offset_right = -6.0
	nav.offset_top = -76.0
	nav.offset_bottom = -6.0
	nav.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.06, 0.13, 0.94), GOLD_DIM, 2, 6))
	add_child(nav)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	nav.add_child(row)
	var tabs := [
		["🏰", "City", "home"],
		["🐣", "Hero", "heroes"],
		["📈", "Growth", "menu:growth"],
		["⚔️", "Campaign", "battle"],
		["🧭", "Adventure", "pve"],
		["🎭", "Contest", "menu:contest"],
		["🏰", "Alliance", "menu:guild"],
	]
	for tab in tabs:
		var b := Button.new()
		b.text = "%s\n%s" % [tab[0], tab[1]]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 10)
		b.add_theme_stylebox_override("normal", _panel_style(Color(0.08, 0.08, 0.15, 0.55), Color(0, 0, 0, 0), 1, 4))
		b.add_theme_stylebox_override("hover", _panel_style(Color(0.16, 0.14, 0.24, 0.9), GOLD, 1, 4))
		b.pressed.connect(func(): _go(str(tab[2])))
		row.add_child(b)


# ---------------------------------------------------------------- theme -----
func _panel_style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(6)
	return sb


# --------------------------------------------------------------- refresh ----
func _refresh() -> void:
	_level_label.text = "Lv.%d" % int(GameManager.progress.get("level", 1))
	_dia_label.text = _fmt(GameManager.progress.get("diamonds", 0))
	_gold_label.text = _fmt(GameManager.progress.get("gold", 0))
	_power_label.text = "⚔️ %s" % _fmt(_team_power())
	if _idle_label != null:
		var r := GameManager.calculate_idle_rewards()
		var mins := int(r["time_elapsed"]) / 60
		_idle_label.text = "💰 %s   ⭐ %s   🎫 %s   (%d mnt)" % [
			_fmt(r["gold"]), _fmt(r["exp"]), str(int(r["tickets"])), mins
		]


func _team_power() -> int:
	var total := 0
	for hero in GameManager.get_player_heroes():
		total += int(hero.get("base_hp", 0)) + int(hero.get("base_atk", 0)) * 5 + int(hero.get("base_def", 0)) * 3
	return total


func _fmt(v) -> String:
	var n := float(v)
	if n >= 1000000.0:
		return "%.2fM" % (n / 1000000.0)
	if n >= 1000.0:
		return "%.1fK" % (n / 1000.0)
	return str(int(n))
