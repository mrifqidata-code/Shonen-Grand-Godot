# scripts/ui/store_ui.gd
# Twilight-style Store: currency tabs (Gold / Diamond / Exchange), a daily
# reward claim, and a grid of goods bought with the matching currency.
extends Control

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")

const CURRENCIES := [
	["gold", "💰"], ["diamonds", "💎"], ["hero_shards", "💠"],
	["tickets", "🎫"], ["advanced_scrolls", "📜"], ["friendship_points", "🤝"],
]

@onready var currency_row: HBoxContainer = $VBox/CurrencyRow
@onready var goods_grid: GridContainer = $VBox/Scroll/GoodsGrid
@onready var status_label: Label = $VBox/StatusLabel
@onready var daily_btn: Button = $VBox/DailyPanel/HBox/DailyBtn

var _tab := "gold"
var _tab_buttons: Dictionary = {}


func _ready() -> void:
	$VBox/HeaderRow/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	daily_btn.pressed.connect(_on_daily)
	for tab in GameConfig.STORE_TABS:
		var btn: Button = $VBox/Tabs.get_node("Tab" + tab.capitalize())
		_tab_buttons[tab] = btn
		btn.pressed.connect(_set_tab.bind(tab))
	_build_currency_row()
	_set_tab("gold")


func _build_currency_row() -> void:
	for entry in CURRENCIES:
		var pill := PanelContainer.new()
		pill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pill.add_theme_stylebox_override("panel", _style(Color(0.06, 0.07, 0.13, 0.95), GOLD_DIM, 1, 6))
		var label := Label.new()
		label.name = str(entry[0])
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 11)
		pill.add_child(label)
		currency_row.add_child(pill)


func _refresh_currency_row() -> void:
	for pill in currency_row.get_children():
		var label := pill.get_child(0) as Label
		var key := str(label.name)
		var icon := ""
		for entry in CURRENCIES:
			if str(entry[0]) == key:
				icon = str(entry[1])
		label.text = "%s %s" % [icon, _fmt(GameManager.progress.get(key, 0))]


func _set_tab(tab: String) -> void:
	_tab = tab
	for key in _tab_buttons:
		var btn: Button = _tab_buttons[key]
		var active: bool = str(key) == tab
		btn.add_theme_stylebox_override(
			"normal",
			_style(Color(0.18, 0.14, 0.08, 0.98) if active else Color(0.08, 0.08, 0.15, 0.9), GOLD if active else GOLD_DIM, 2, 8)
		)
		btn.add_theme_color_override("font_color", Color(1, 0.9, 0.6) if active else Color(0.8, 0.82, 0.9))
	_rebuild_goods()
	daily_btn.disabled = not GameManager.can_claim_daily()
	daily_btn.text = "Klaim" if GameManager.can_claim_daily() else "Sudah"
	_refresh_currency_row()
	status_label.text = ""


func _rebuild_goods() -> void:
	for child in goods_grid.get_children():
		child.queue_free()
	var goods: Array = GameConfig.STORE_GOODS.get(_tab, [])
	for item in goods:
		goods_grid.add_child(_goods_card(item))
	_refresh_currency_row()


func _goods_card(item: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 150)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 10))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)

	var icon := Label.new()
	icon.text = str(item["icon"])
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 34)
	box.add_child(icon)

	var name_label := Label.new()
	name_label.text = str(item["name"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	box.add_child(name_label)

	var cost_key := str(item["cost_key"])
	var cost := int(item["cost"])
	var afford := int(GameManager.progress.get(cost_key, 0)) >= cost
	var price := Label.new()
	price.text = "%s %d" % [_currency_icon(cost_key), cost]
	price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price.add_theme_font_size_override("font_size", 13)
	price.add_theme_color_override("font_color", GOLD if afford else Color(0.85, 0.4, 0.4))
	box.add_child(price)

	var buy := Button.new()
	buy.text = "Beli"
	buy.disabled = not afford
	buy.pressed.connect(_on_buy.bind(item))
	box.add_child(buy)
	return card


func _currency_icon(key: String) -> String:
	for entry in CURRENCIES:
		if str(entry[0]) == key:
			return str(entry[1])
	return "🪙"


func _on_buy(item: Dictionary) -> void:
	if GameManager.buy_goods(item):
		status_label.text = "✅ %s dibeli." % item["name"]
		status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
		_rebuild_goods()
	else:
		status_label.text = "❌ %s tidak cukup." % _currency_icon(str(item["cost_key"]))
		status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))


func _on_daily() -> void:
	if GameManager.claim_daily():
		status_label.text = "📅 Daily reward diklaim!"
		status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
	else:
		status_label.text = "Daily sudah diklaim hari ini."
	_update_refresh()


func _update_refresh() -> void:
	daily_btn.disabled = not GameManager.can_claim_daily()
	daily_btn.text = "Klaim" if GameManager.can_claim_daily() else "Sudah"
	_refresh_currency_row()
	_rebuild_goods()


func _fmt(v) -> String:
	var n := float(v)
	if n >= 1000000.0:
		return "%.2fM" % (n / 1000000.0)
	if n >= 1000.0:
		return "%.1fK" % (n / 1000.0)
	return str(int(n))


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(6)
	return sb
