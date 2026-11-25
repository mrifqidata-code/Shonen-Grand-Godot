# scripts/ui/heroes_ui.gd
# Hero collection as a portrait-card grid: rarity frame, stars, level, and a
# detail sheet with Upgrade / Star Up. Layout mirrors a mobile idle-RPG roster.
extends Control

const CharacterViewScript := preload("res://scripts/ui/character_view.gd")

const RARITY_ORDER := ["N", "R", "SR", "SSR", "SSR+", "UR", "EX"]
const RARITY_COLORS := {
	"N": Color(0.62, 0.64, 0.70),
	"R": Color(0.48, 0.79, 0.52),
	"SR": Color(0.36, 0.60, 0.95),
	"SSR": Color(0.60, 0.36, 0.95),
	"SSR+": Color(0.25, 0.75, 0.95),
	"UR": Color(0.98, 0.40, 0.75),
	"EX": Color(0.98, 0.75, 0.14),
}
const GOLD := Color("d8b24a")

@onready var hero_grid: GridContainer = $VBox/Scroll/HeroGrid
@onready var count_label: Label = $VBox/Header/CountLabel
@onready var sort_btn: Button = $VBox/Header/SortBtn
@onready var detail_panel: PanelContainer = $DetailPanel
@onready var detail_portrait: Control = $DetailPanel/VBox/DetailPortrait
@onready var detail_name: Label = $DetailPanel/VBox/DetailName
@onready var detail_meta: Label = $DetailPanel/VBox/DetailMeta
@onready var detail_stats: Label = $DetailPanel/VBox/DetailStats
@onready var upgrade_btn: Button = $DetailPanel/VBox/DetailButtons/UpgradeBtn
@onready var star_btn: Button = $DetailPanel/VBox/DetailButtons/StarBtn
@onready var limit_btn: Button = $DetailPanel/VBox/DetailButtons/LimitBtn
@onready var grade_btn: Button = $DetailPanel/VBox/DetailButtons2/GradeBtn
@onready var awaken_btn: Button = $DetailPanel/VBox/DetailButtons2/AwakenBtn
@onready var close_btn: Button = $DetailPanel/VBox/CloseBtn

var _sort_mode := 0  # 0 rarity, 1 level, 2 name
var _selected_id := ""


func _ready() -> void:
	$VBox/Header/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	sort_btn.pressed.connect(_cycle_sort)
	close_btn.pressed.connect(func(): detail_panel.visible = false)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	star_btn.pressed.connect(_on_star_pressed)
	limit_btn.pressed.connect(_on_limit_pressed)
	grade_btn.pressed.connect(_on_grade_pressed)
	awaken_btn.pressed.connect(_on_awaken_pressed)
	_style_detail_panel()
	refresh_heroes()


func _style_detail_panel() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.14, 0.98)
	style.border_color = GOLD
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	detail_panel.add_theme_stylebox_override("panel", style)


func _cycle_sort() -> void:
	_sort_mode = (_sort_mode + 1) % 3
	sort_btn.text = ["Urut: Rarity", "Urut: Level", "Urut: Nama"][_sort_mode]
	refresh_heroes()


func _sorted_heroes() -> Array:
	var heroes := GameManager.heroes.duplicate()
	match _sort_mode:
		1:
			heroes.sort_custom(func(a, b): return int(a.get("level", 1)) > int(b.get("level", 1)))
		2:
			heroes.sort_custom(func(a, b): return str(a.get("hero_name", "")) < str(b.get("hero_name", "")))
		_:
			heroes.sort_custom(func(a, b):
				var ia := GameConfig.rarity_rank(str(a.get("rarity", "SR")))
				var ib := GameConfig.rarity_rank(str(b.get("rarity", "SR")))
				if ia != ib:
					return ia > ib
				return int(a.get("level", 1)) > int(b.get("level", 1))
			)
	return heroes


func refresh_heroes() -> void:
	for child in hero_grid.get_children():
		child.queue_free()

	var heroes := _sorted_heroes()
	count_label.text = "(%d)" % heroes.size()

	if heroes.is_empty():
		var empty := Label.new()
		empty.text = "Belum ada hero.\nSummon dulu di menu Summon."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hero_grid.add_child(empty)
		return

	for hero in heroes:
		hero_grid.add_child(_hero_card(hero))


func _hero_card(hero: Dictionary) -> PanelContainer:
	var rarity := str(hero.get("rarity", "SSR"))
	var color: Color = RARITY_COLORS.get(rarity, Color(0.5, 0.5, 0.6))

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 200)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _card_style(color))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	card.add_child(box)

	var view := CharacterViewScript.new()
	view.custom_minimum_size = Vector2(128, 128)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	view.style_id = GameManager.get_character_style()
	view.anime_origin = str(hero.get("anime_origin", "Default"))
	view.hero_id = HeroesData.template_id_of(hero)
	box.add_child(view)

	var name_label := Label.new()
	name_label.text = str(hero.get("hero_name", "Hero")).split(" ")[0]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", color)
	box.add_child(name_label)

	var stars := Label.new()
	stars.text = "★".repeat(int(hero.get("star_level", 1))) + "  Lv.%d" % int(hero.get("level", 1))
	stars.text += "  G%d" % (int(hero.get("grade", 0)) + 1)
	if int(hero.get("awaken", 0)) > 0:
		stars.text += " A%d" % int(hero.get("awaken", 0))
	stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars.add_theme_font_size_override("font_size", 10)
	stars.add_theme_color_override("font_color", GOLD)
	box.add_child(stars)

	var footer := Label.new()
	footer.text = "%s · %s" % [hero.get("hero_class", "-"), str(hero.get("anime_origin", "-")).split(" ")[0]]
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 9)
	footer.add_theme_color_override("font_color", Color(0.65, 0.68, 0.78))
	box.add_child(footer)

	card.mouse_filter = Control.MOUSE_FILTER_STOP
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_detail(str(hero["id"]))
	)
	return card


func _card_style(color: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.08, 0.16, 0.94)
	sb.border_color = color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(8)
	return sb


func _open_detail(hero_id: String) -> void:
	var hero := GameManager.get_hero_by_id(hero_id)
	if hero.is_empty():
		return
	_selected_id = hero_id
	var rarity := str(hero.get("rarity", "SSR"))
	var color: Color = RARITY_COLORS.get(rarity, Color.WHITE)

	for child in detail_portrait.get_children():
		child.queue_free()
	var view := CharacterViewScript.new()
	view.custom_minimum_size = Vector2(160, 160)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	view.style_id = GameManager.get_character_style()
	view.anime_origin = str(hero.get("anime_origin", "Default"))
	view.hero_id = HeroesData.template_id_of(hero)
	view.animate_idle = true
	detail_portrait.add_child(view)

	detail_name.text = str(hero.get("hero_name", "Hero"))
	detail_name.add_theme_color_override("font_color", color)
	var faction_name := Faction.display_name(int(hero.get("faction", 0)))
	detail_meta.text = "%s · %s · %s\n%s" % [
		rarity, hero.get("hero_class", "-"), hero.get("anime_origin", "-"), faction_name
	]
	var cap := GameManager.hero_level_cap(hero)
	var grade := int(hero.get("grade", 0))
	var awaken := int(hero.get("awaken", 0))
	detail_stats.text = "★ %d · Lv.%d/%d · LB%d · G%d · A%d\nHP %d · ATK %d · DEF %d · Power %d" % [
		int(hero.get("star_level", 1)),
		int(hero.get("level", 1)),
		cap,
		int(hero.get("limit_break", 0)),
		grade + 1,
		awaken,
		int(hero.get("base_hp", 0)),
		int(hero.get("base_atk", 0)),
		int(hero.get("base_def", 0)),
		GameManager.hero_power(hero),
	]
	var maxed: bool = int(hero.get("level", 1)) >= cap
	upgrade_btn.text = "Level MAX" if maxed else "Upgrade (%dg)" % (int(hero.get("level", 1)) * 50)
	upgrade_btn.disabled = maxed
	var lb_maxed: bool = int(hero.get("limit_break", 0)) >= GameConfig.MAX_LIMIT_BREAK
	limit_btn.text = "Limit MAX" if lb_maxed else "Limit Break (%d💠)" % GameManager.limit_break_cost(hero)
	limit_btn.disabled = lb_maxed or int(GameManager.progress.get("hero_shards", 0)) < GameManager.limit_break_cost(hero)

	# Grade: 7 tiers from HeroGradeCfg. Awaken unlocks once grade is maxed.
	var grade_maxed: bool = grade >= GameConfig.GRADE_COUNT - 1
	if grade_maxed:
		grade_btn.text = "Grade MAX"
		grade_btn.disabled = true
	else:
		var gcost := GameConfig.grade_cost(grade)
		grade_btn.text = "Grade →G%d\n%dg + %d💠" % [grade + 2, int(gcost["gold"]), int(gcost["hero_shards"])]
		grade_btn.disabled = (
			int(GameManager.progress.get("gold", 0)) < int(gcost["gold"])
			or int(GameManager.progress.get("hero_shards", 0)) < int(gcost["hero_shards"])
		)
	if awaken >= GameConfig.AWAKEN_MAX:
		awaken_btn.text = "Awaken MAX"
		awaken_btn.disabled = true
	elif not grade_maxed:
		awaken_btn.text = "Awaken (G%d dulu)" % GameConfig.GRADE_COUNT
		awaken_btn.disabled = true
	else:
		var acost := GameConfig.awaken_cost(awaken)
		awaken_btn.text = "Awaken →A%d\n%d💫 + %d🔮" % [awaken + 1, int(acost["courage_essence"]), int(acost["soul_crystal"])]
		awaken_btn.disabled = (
			int(GameManager.progress.get("courage_essence", 0)) < int(acost["courage_essence"])
			or int(GameManager.progress.get("soul_crystal", 0)) < int(acost["soul_crystal"])
		)
	detail_panel.visible = true


## Opens the detail sheet for the first owned hero (screenshot tooling).
func open_first_hero() -> void:
	if GameManager.heroes.is_empty():
		return
	_open_detail(str(GameManager.heroes[0]["id"]))


func _on_grade_pressed() -> void:
	if _selected_id.is_empty():
		return
	if GameManager.grade_hero(_selected_id):
		refresh_heroes()
		_open_detail(_selected_id)


func _on_awaken_pressed() -> void:
	if _selected_id.is_empty():
		return
	if GameManager.awaken_hero(_selected_id):
		refresh_heroes()
		_open_detail(_selected_id)


func _on_limit_pressed() -> void:
	if _selected_id.is_empty():
		return
	if GameManager.limit_break_hero(_selected_id):
		refresh_heroes()
		_open_detail(_selected_id)


func _on_upgrade_pressed() -> void:
	if _selected_id.is_empty():
		return
	if GameManager.upgrade_hero(_selected_id):
		refresh_heroes()
		_open_detail(_selected_id)


func _on_star_pressed() -> void:
	if _selected_id.is_empty():
		return
	if GameManager.star_up_hero(_selected_id):
		refresh_heroes()
		_open_detail(_selected_id)