# scripts/ui/summon_ui.gd
# Summon hub with the four banners from GameConfig (Hero / Friendship / Advanced /
# Race). Odds, cost and pity follow the Twilight Chronicle datamine: each pull
# rolls a rarity tier by weight, every 10x guarantees a mid tier, and 100 pulls
# guarantee the top tier. The rate table and pity bar are shown to the player.
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
@onready var faction_row: HBoxContainer = $VBox/FactionRow

var _featured_hero_id := ""
var _tab := 0
var _faction := 0
var _tab_buttons: Array = []
var _rate_label: Label
var _pity_label: Label
var _pity_bar: ProgressBar


func _ready() -> void:
	$VBox/HeaderRow/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	summon1_btn.pressed.connect(func(): _on_summon(1))
	summon10_btn.pressed.connect(func(): _on_summon(10))
	ok_btn.pressed.connect(func(): result_panel.visible = false)
	result_panel.add_theme_stylebox_override(
		"panel", _style(Color(0.08, 0.07, 0.15, 0.98), GOLD, 2, 12)
	)
	_build_tabs()
	_build_factions()
	_build_rate_panel()
	_build_banner()
	_set_tab(0)


func _build_tabs() -> void:
	var tabs: HBoxContainer = $VBox/Tabs
	for i in range(GameConfig.BANNERS.size()):
		var btn: Button = tabs.get_node("Tab" + str(GameConfig.BANNERS[i]["label"]))
		_tab_buttons.append(btn)
		btn.pressed.connect(_set_tab.bind(i))


func _build_factions() -> void:
	for i in range(FACTIONS.size()):
		var btn := Button.new()
		btn.text = FACTIONS[i]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 11)
		btn.pressed.connect(_select_faction.bind(i))
		faction_row.add_child(btn)


const FACTIONS := ["Lightforged", "Arcane", "Kindred", "Demonhunt", "Void"]


func _build_rate_panel() -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(Color(0.06, 0.06, 0.13, 0.94), GOLD_DIM, 1, 8))
	$VBox.add_child(panel)
	$VBox.move_child(panel, $VBox/StatusLabel.get_index())

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)

	_rate_label = Label.new()
	_rate_label.add_theme_font_size_override("font_size", 12)
	_rate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_rate_label)

	var pity_row := HBoxContainer.new()
	pity_row.add_theme_constant_override("separation", 6)
	box.add_child(pity_row)
	_pity_label = Label.new()
	_pity_label.add_theme_font_size_override("font_size", 11)
	_pity_label.add_theme_color_override("font_color", Color(0.75, 0.78, 0.88))
	pity_row.add_child(_pity_label)
	_pity_bar = ProgressBar.new()
	_pity_bar.min_value = 0
	_pity_bar.max_value = GameConfig.PITY_MAX
	_pity_bar.show_percentage = false
	_pity_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pity_bar.custom_minimum_size = Vector2(0, 10)
	_pity_bar.add_theme_stylebox_override("background", _style(Color(0.10, 0.10, 0.18), Color(0, 0, 0, 0), 0, 4))
	_pity_bar.add_theme_stylebox_override("fill", _style(GOLD, Color(0, 0, 0, 0), 0, 4))
	pity_row.add_child(_pity_bar)


func _set_tab(index: int) -> void:
	_tab = index
	for i in range(_tab_buttons.size()):
		var btn: Button = _tab_buttons[i]
		var active := i == index
		btn.add_theme_stylebox_override(
			"normal",
			_style(Color(0.18, 0.14, 0.08, 0.98) if active else Color(0.08, 0.08, 0.15, 0.9), GOLD if active else GOLD_DIM, 2, 8)
		)
		btn.add_theme_color_override("font_color", Color(1, 0.9, 0.6) if active else Color(0.8, 0.82, 0.9))
	faction_row.visible = index == 3
	var banner: Dictionary = GameConfig.BANNERS[index]
	_rate_label.text = "Rate: " + GameConfig.rate_line(banner)
	_rate_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.98))
	_pity_label.text = "Pity %d/%d%s" % [
		_pity_value(),
		GameConfig.PITY_MAX,
		" · 10× jaminan UR" if bool(banner.get("ten_guarantee", false)) else "",
	]
	_pity_bar.value = _pity_value()
	status_label.text = str(banner.get("blurb", ""))
	status_label.add_theme_color_override("font_color", Color(0.65, 0.68, 0.78))
	_update_prices()
	_build_featured()


func _select_faction(index: int) -> void:
	_faction = index
	for i in range(faction_row.get_child_count()):
		var btn: Button = faction_row.get_child(i)
		btn.add_theme_stylebox_override(
			"normal",
			_style(Color(0.18, 0.12, 0.24, 0.98), GOLD, 2, 8) if i == index else _style(Color(0.08, 0.08, 0.15, 0.9), GOLD_DIM, 1, 8)
		)
	_build_featured()


func _pity_value() -> int:
	return int(GameManager.progress.get("noble_insignia", 0))


func _update_prices() -> void:
	var banner: Dictionary = GameConfig.BANNERS[_tab]
	var amount := int(GameManager.progress.get(str(banner["key"]), 0))
	ticket_label.text = "%s %d %s" % [banner["icon"], amount, banner["unit"]]
	var per := int(banner["per"])
	summon1_btn.text = "Summon ×1\n%s %d" % [banner["icon"], per]
	summon10_btn.text = "Summon ×10\n%s %d" % [banner["icon"], per * 10]
	summon10_btn.disabled = amount < per * 10
	summon1_btn.disabled = amount < per


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


func _pool() -> Array:
	var banner: Dictionary = GameConfig.BANNERS[_tab]
	var tiers: Array = banner.get("pool_tiers", [0, 1, 2])
	var all := HeroesData.get_all_templates()
	return all.filter(func(t):
		var ok := tiers.has(GameConfig.tier_of(str(t["rarity"])))
		if _tab == 3:
			ok = ok and int(t["faction"]) == _faction
		return ok
	)


func _pool_for_tier(pool: Array, min_tier: int) -> Array:
	var out := pool.filter(func(t): return GameConfig.tier_of(str(t["rarity"])) >= min_tier)
	return out if not out.is_empty() else pool


func _build_featured() -> void:
	for child in featured_grid.get_children():
		child.queue_free()
	var order := ["EX", "UR+", "UR", "SSR+", "SSR"]
	var heroes := _pool()
	heroes.sort_custom(func(a, b):
		var ia := order.find(str(a["rarity"]))
		var ib := order.find(str(b["rarity"]))
		if ia == -1:
			ia = 99
		if ib == -1:
			ib = 99
		return ia < ib
	)
	for t in heroes:
		featured_grid.add_child(_hero_card(t, 64))


func _hero_card(template: Dictionary, sprite_px: int) -> PanelContainer:
	var rarity := str(template["rarity"])
	var color: Color = RARITY_COLORS.get(rarity, Color.WHITE)
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	var banner: Dictionary = GameConfig.BANNERS[_tab]
	var key := str(banner["key"])
	var per := int(banner["per"])
	var total_cost := per * count
	if int(GameManager.progress.get(key, 0)) < total_cost:
		status_label.text = "%s tidak cukup (%d/%d). Klaim Idle Reward / battle dulu." % [
			banner["icon"], int(GameManager.progress.get(key, 0)), total_cost
		]
		status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
		return

	var pool := _pool()
	if pool.is_empty():
		status_label.text = "Pool kosong untuk pilihan ini."
		return

	var pulled_heroes := []
	var best_tier := -1
	for i in range(count):
		if not GameManager.spend_progress(key, per):
			break
		var tier := _roll_tier(banner, count, i, best_tier)
		best_tier = maxi(best_tier, tier)
		var tier_pool := _pool_for_tier(pool, tier)
		# Prefer an exact-tier template so the rolled rarity is honoured.
		var exact := tier_pool.filter(func(t): return GameConfig.tier_of(str(t["rarity"])) == tier)
		var template: Dictionary = exact[randi() % exact.size()] if not exact.is_empty() else tier_pool[randi() % tier_pool.size()]
		var hero = HeroesData.create_hero_from_template(template)
		GameManager.add_hero(hero)
		pulled_heroes.append(hero)
		if _owns_template(str(template["id"]), hero["id"]):
			GameManager.add_progress("hero_shards", 10)

	GameManager.save_game()
	if pulled_heroes.is_empty():
		_update_prices()
		return

	_show_results(pulled_heroes)
	var best := _best_rarity(pulled_heroes)
	var color: Color = RARITY_COLORS.get(best, Color.WHITE)
	status_label.text = "✨ %s ×%d · terbaik: %s · Pity %d/%d · Tim %d/6" % [
		banner["label"], pulled_heroes.size(), best, _pity_value(), GameConfig.PITY_MAX,
		GameManager.get_team_hero_count(),
	]
	status_label.add_theme_color_override("font_color", color)
	_update_prices()
	_pity_bar.value = _pity_value()
	_pity_label.text = "Pity %d/%d%s" % [
		_pity_value(), GameConfig.PITY_MAX,
		" · 10× jaminan UR" if bool(banner.get("ten_guarantee", false)) else "",
	]


## Rolls a rarity tier: hard pity at 100, 10x guarantees a mid tier on the last
## pull, otherwise a weighted roll from the banner's rate table.
func _roll_tier(banner: Dictionary, count: int, index: int, best_so_far: int) -> int:
	if _pity_value() >= GameConfig.PITY_MAX - 1:
		GameManager.progress["noble_insignia"] = 0
		return 2
	var weights: Array = banner.get("weights", [8900, 850, 250])
	var tier := _weighted_tier(weights)
	if count >= 10 and bool(banner.get("ten_guarantee", false)) and index == count - 1 and best_so_far < 1:
		tier = 1
	GameManager.add_progress("noble_insignia", 1)
	return tier


func _weighted_tier(weights: Array) -> int:
	var total := 0
	for w in weights:
		total += int(w)
	var roll := randi() % maxi(total, 1)
	var acc := 0
	for i in range(weights.size()):
		acc += int(weights[i])
		if roll < acc:
			return i
	return 0


func _owns_template(template_id: String, new_hero_id: String) -> bool:
	var count := 0
	for hero in GameManager.heroes:
		if str(hero.get("template_id", "")) == template_id and str(hero.get("id", "")) != new_hero_id:
			count += 1
	return count > 0


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
