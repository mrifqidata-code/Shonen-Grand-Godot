# scripts/ui/summon_ui.gd
# Hero Summon screen styled like a gacha banner: rate-up showcase, ticket count,
# x1/x10 buttons and a result grid with rarity-coloured hero cards.
extends Control

const CharacterViewScript := preload("res://scripts/ui/character_view.gd")

const RARITY_COLORS := {
	"SSR": Color(0.80, 0.80, 0.85),
	"SSR+": Color(0.25, 0.55, 1.00),
	"UR": Color(0.62, 0.32, 0.95),
	"UR+": Color(0.95, 0.32, 0.72),
	"EX": Color(0.98, 0.75, 0.14),
}
const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")

@onready var ticket_label: Label = $VBox/TicketPanel/HBox/TicketLabel
@onready var summon1_btn: Button = $VBox/SummonRow/Summon1Btn
@onready var summon10_btn: Button = $VBox/SummonRow/Summon10Btn
@onready var status_label: Label = $VBox/StatusLabel
@onready var banner_art: Control = $VBox/Banner/HBox/BannerArt
@onready var banner_name: Label = $VBox/Banner/HBox/BannerInfo/BannerName
@onready var banner_meta: Label = $VBox/Banner/HBox/BannerInfo/BannerMeta
@onready var featured_grid: GridContainer = $VBox/Scroll/FeaturedGrid
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_card: VBoxContainer = $ResultPanel/VBox/ResultCard
@onready var result_grid: GridContainer = $ResultPanel/VBox/ResultGrid
@onready var ok_btn: Button = $ResultPanel/VBox/OkBtn

var _featured_hero_id := ""


func _ready() -> void:
	$VBox/HeaderRow/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	summon1_btn.pressed.connect(func(): _on_summon(1))
	summon10_btn.pressed.connect(func(): _on_summon(10))
	ok_btn.pressed.connect(func(): result_panel.visible = false)
	result_panel.add_theme_stylebox_override(
		"panel", _style(Color(0.08, 0.07, 0.15, 0.98), GOLD, 2, 12)
	)
	_build_banner()
	_build_featured()
	update_ticket_label()


func update_ticket_label() -> void:
	ticket_label.text = "%d ticket" % int(GameManager.progress["tickets"])


func _build_banner() -> void:
	var templates := HeroesData.get_all_templates()
	var pick: Dictionary = {}
	for t in templates:
		if str(t["rarity"]) == "EX":
			pick = t
			break
		if pick.is_empty() and str(t["rarity"]) in ["UR+", "UR", "SSR+"]:
			pick = t
	if pick.is_empty():
		return
	_featured_hero_id = str(pick["id"])
	banner_name.text = str(pick["hero_name"])
	banner_name.add_theme_color_override("font_color", RARITY_COLORS.get(str(pick["rarity"]), Color.WHITE))
	banner_meta.text = "%s · %s · %s" % [pick["rarity"], pick["hero_class"], pick["anime_origin"]]

	var view := CharacterViewScript.new()
	view.custom_minimum_size = Vector2(192, 192)
	view.style_id = GameManager.get_character_style()
	view.anime_origin = str(pick["anime_origin"])
	view.hero_id = _featured_hero_id
	banner_art.add_child(view)


func _build_featured() -> void:
	for child in featured_grid.get_children():
		child.queue_free()
	var order := ["EX", "UR+", "UR", "SSR+", "SSR"]
	var all := HeroesData.get_all_templates()
	all.sort_custom(func(a, b):
		var ia := order.find(str(a["rarity"]))
		var ib := order.find(str(b["rarity"]))
		if ia == -1:
			ia = 99
		if ib == -1:
			ib = 99
		return ia < ib
	)
	for t in all:
		featured_grid.add_child(_hero_card(t, 64))


func _hero_card(template: Dictionary, sprite_px: int) -> PanelContainer:
	var rarity := str(template["rarity"])
	var color: Color = RARITY_COLORS.get(rarity, Color.WHITE)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _style(Color(0.07, 0.07, 0.14, 0.95), color, 2, 8))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	card.add_child(box)

	var view := CharacterViewScript.new()
	view.custom_minimum_size = Vector2(sprite_px, sprite_px)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	view.style_id = GameManager.get_character_style()
	view.anime_origin = str(template["anime_origin"])
	var hid := str(template.get("template_id", ""))
	if hid.is_empty():
		hid = str(template["id"])
	view.hero_id = hid
	box.add_child(view)

	var name_label := Label.new()
	name_label.text = str(template["hero_name"]).split(" ")[0]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", color)
	box.add_child(name_label)

	var rarity_label := Label.new()
	rarity_label.text = rarity
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_font_size_override("font_size", 9)
	rarity_label.add_theme_color_override("font_color", Color(0.7, 0.72, 0.8))
	box.add_child(rarity_label)

	return card


func _on_summon(count: int) -> void:
	if int(GameManager.progress["tickets"]) < count:
		status_label.text = "🎫 Ticket tidak cukup (%d/%d). Klaim Idle Reward dulu di City." % [
			int(GameManager.progress["tickets"]), count
		]
		status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
		return

	var pulled_heroes := []
	var templates := HeroesData.get_all_templates()
	for i in range(count):
		if not GameManager.spend_tickets(1):
			break
		var template = templates[randi() % templates.size()]
		var hero = HeroesData.create_hero_from_template(template)
		GameManager.add_hero(hero)
		pulled_heroes.append(hero)

	if pulled_heroes.is_empty():
		return

	_show_results(pulled_heroes)
	var best := _best_rarity(pulled_heroes)
	var color: Color = RARITY_COLORS.get(best, Color.WHITE)
	status_label.text = "✨ %d hero didapat · terbaik: %s · Tim: %d/6" % [
		pulled_heroes.size(), best, GameManager.get_team_hero_count()
	]
	status_label.add_theme_color_override("font_color", color)
	update_ticket_label()


func _show_results(heroes: Array) -> void:
	for child in result_card.get_children():
		child.queue_free()
	for child in result_grid.get_children():
		child.queue_free()
	result_panel.visible = true

	if heroes.size() == 1:
		var hero: Dictionary = heroes[0]
		var color: Color = RARITY_COLORS.get(str(hero["rarity"]), Color.WHITE)
		var view := CharacterViewScript.new()
		view.custom_minimum_size = Vector2(128, 128)
		view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		view.style_id = GameManager.get_character_style()
		view.anime_origin = str(hero["anime_origin"])
		view.hero_id = str(hero.get("template_id", ""))
		view.play("victory")
		result_card.add_child(view)
		var name_label := Label.new()
		name_label.text = str(hero["hero_name"])
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 20)
		name_label.add_theme_color_override("font_color", color)
		result_card.add_child(name_label)
		var info := Label.new()
		info.text = "%s · %s · %s" % [hero["rarity"], hero["hero_class"], hero["anime_origin"]]
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		info.add_theme_font_size_override("font_size", 12)
		info.add_theme_color_override("font_color", Color(0.7, 0.72, 0.8))
		result_card.add_child(info)
	else:
		result_grid.columns = 5
		for hero in heroes:
			result_grid.add_child(_hero_card(hero, 48))


func _best_rarity(heroes: Array) -> String:
	var order := ["SSR", "SSR+", "UR", "UR+", "EX"]
	var best := 0
	for hero in heroes:
		var idx := order.find(str(hero["rarity"]))
		if idx > best:
			best = idx
	return order[best]


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(8)
	return sb
