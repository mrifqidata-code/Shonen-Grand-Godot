# scripts/ui/inventory_ui.gd
# Bag: shows every tracked resource and material the player owns, following the
# Twilight inventory idea (currencies + upgrade materials in one grid).
extends Control

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")

const ITEMS := [
	{"key": "gold", "name": "Gold", "icon": "💰", "desc": "Upgrade hero & beli di Store"},
	{"key": "diamonds", "name": "Diamond", "icon": "💎", "desc": "Summon Race & paket"},
	{"key": "tickets", "name": "Summon Ticket", "icon": "🎫", "desc": "Banner Hero"},
	{"key": "friendship_points", "name": "Friendship Point", "icon": "🤝", "desc": "Banner Friendship"},
	{"key": "advanced_scrolls", "name": "Advanced Scroll", "icon": "📜", "desc": "Banner Advanced"},
	{"key": "noble_insignia", "name": "Noble Insignia", "icon": "🏅", "desc": "Pity (100 = jaminan EX)"},
	{"key": "hero_shards", "name": "Hero Shard", "icon": "💠", "desc": "Limit Break & Exchange"},
	{"key": "star_shards", "name": "Star Shard", "icon": "⭐", "desc": "Star up hero"},
]

@onready var item_grid = $VBox/ItemGrid


func _ready():
	$VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	refresh_items()


func refresh_items():
	for child in item_grid.get_children():
		child.queue_free()
	for item in ITEMS:
		var count = int(GameManager.progress.get(str(item["key"]), 0))
		item_grid.add_child(_item_card(item, count))


func _item_card(item: Dictionary, count: int) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 110)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 10))

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	var icon = Label.new()
	icon.text = str(item["icon"])
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 30)
	vbox.add_child(icon)

	var name_l = Label.new()
	name_l.text = str(item["name"])
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 12)
	vbox.add_child(name_l)

	var desc = Label.new()
	desc.text = str(item["desc"])
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 9)
	desc.add_theme_color_override("font_color", Color(0.6, 0.6, 0.68))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)

	var count_l = Label.new()
	count_l.text = _fmt(count)
	count_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_l.add_theme_font_size_override("font_size", 17)
	count_l.add_theme_color_override("font_color", GOLD)
	vbox.add_child(count_l)

	return panel


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
