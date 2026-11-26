# scripts/ui/market_ui.gd
# Daily market (Twilight MarketGoods): a small rotating shop that refreshes
# every day. Goods cost gold or diamonds and grant tracked resources.
extends Control

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")

@onready var goods_grid: GridContainer = $VBox/Scroll/GoodsGrid
@onready var status_label: Label = $VBox/StatusLabel
@onready var refresh_label: Label = $VBox/RefreshLabel


func _ready() -> void:
	$VBox/HeaderRow/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	_build()


func _build() -> void:
	refresh_label.text = "Refresh: %s" % GameManager.market_today()
	for child in goods_grid.get_children():
		child.queue_free()
	var goods := GameManager.market_goods()
	for entry in goods:
		goods_grid.add_child(_card(entry))


func _card(entry: Dictionary) -> PanelContainer:
	var good: Dictionary = entry["good"]
	var idx: int = int(entry["index"])
	var bought: bool = bool(entry["bought"])
	var cost_key := str(good["cost_key"])
	var cost := int(good["cost"])
	var afford := int(GameManager.progress.get(cost_key, 0)) >= cost

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 150)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 10))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)

	var icon := Label.new()
	icon.text = str(good["icon"])
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 34)
	box.add_child(icon)

	var name_label := Label.new()
	name_label.text = str(good["name"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	box.add_child(name_label)

	var price := Label.new()
	price.text = "%s %d" % [_icon(cost_key), cost]
	price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price.add_theme_font_size_override("font_size", 13)
	price.add_theme_color_override("font_color", GOLD if afford else Color(0.85, 0.4, 0.4))
	box.add_child(price)

	var buy := Button.new()
	if bought:
		buy.text = "Terbeli"
		buy.disabled = true
	else:
		buy.text = "Beli"
		buy.disabled = not afford
		buy.pressed.connect(_buy.bind(idx))
	box.add_child(buy)
	return card


func _icon(key: String) -> String:
	match key:
		"gold": return "💰"
		"diamonds": return "💎"
		"hero_shards": return "💠"
		_: return "🪙"


func _buy(index: int) -> void:
	if GameManager.buy_market_good(index):
		status_label.text = "✅ Dibeli."
		status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
	else:
		status_label.text = "❌ Tidak cukup / sudah dibeli."
		status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
	_build()


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(6)
	return sb
