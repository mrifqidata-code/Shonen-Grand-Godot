# scripts/ui/team_ui.gd
# Formation screen. Twilight Chronicle (FormationCfg) splits the six slots into
# a front row that soaks damage and a back row for DPS/support, so the slots are
# shown as two labelled rows instead of a flat grid.
extends Control

const CharacterViewScript := preload("res://scripts/ui/character_view.gd")

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")
const FRONT_COLOR := Color("5aa9e6")
const BACK_COLOR := Color("b06cff")

@onready var slots_grid = $VBox/TeamPanel/VBox/SlotsGrid
@onready var hero_list = $VBox/Scroll/HeroList

var _slots_box: VBoxContainer


func _ready():
	$VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	# SlotsGrid used to hold the six slot panels directly; now it wraps one VBox.
	slots_grid.columns = 1
	_slots_box = VBoxContainer.new()
	_slots_box.add_theme_constant_override("separation", 8)
	slots_grid.add_child(_slots_box)
	refresh_ui()


func refresh_ui():
	for child in _slots_box.get_children():
		child.queue_free()
	for child in hero_list.get_children():
		child.queue_free()

	var team = GameManager.get_team()
	var heroes = GameManager.heroes
	var slots: Array = team.get("slots", [])

	# FormationCfg rows: positions 1-3 hold the line, 4-6 deal damage.
	_slots_box.add_child(_row_header("⚔️ Depan · menahan damage", FRONT_COLOR))
	_slots_box.add_child(_slot_row(slots, 0, 3))
	_slots_box.add_child(_row_header("🏹 Belakang · DPS & support", BACK_COLOR))
	_slots_box.add_child(_slot_row(slots, 3, 6))

	_build_hero_list(team, heroes)


func _row_header(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", color)
	return label


func _slot_row(slots: Array, from: int, to: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	for i in range(from, mini(to, slots.size())):
		row.add_child(_slot_panel(slots[i], i < 3))
	return row


func _slot_panel(slot: Dictionary, is_front: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 118)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var accent := FRONT_COLOR if is_front else BACK_COLOR
	panel.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), accent, 2, 8))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)

	var pos_label = Label.new()
	pos_label.text = "Slot %d" % int(slot["position"])
	pos_label.add_theme_font_size_override("font_size", 9)
	pos_label.add_theme_color_override("font_color", Color(0.55, 0.58, 0.68))
	box.add_child(pos_label)

	if slot["hero_id"] != null:
		var hero = GameManager.get_hero_by_id(slot["hero_id"])
		if not hero.is_empty():
			var view := CharacterViewScript.new()
			view.custom_minimum_size = Vector2(64, 64)
			view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			view.style_id = GameManager.get_character_style()
			view.anime_origin = str(hero.get("anime_origin", "Default"))
			view.hero_id = HeroesData.template_id_of(hero)
			box.add_child(view)

			var name_label = Label.new()
			name_label.text = str(hero["hero_name"]).split(" ")[0]
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_label.add_theme_font_size_override("font_size", 11)
			name_label.add_theme_color_override("font_color", GOLD)
			box.add_child(name_label)

			var info = Label.new()
			info.text = "Lv.%d ★%d" % [hero["level"], hero["star_level"]]
			info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			info.add_theme_font_size_override("font_size", 9)
			box.add_child(info)

			var remove_btn = Button.new()
			remove_btn.text = "Lepas"
			remove_btn.add_theme_font_size_override("font_size", 10)
			remove_btn.pressed.connect(func(): _on_remove(slot["position"]))
			box.add_child(remove_btn)
	else:
		var empty = Label.new()
		empty.text = "Kosong"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
		empty.add_theme_font_size_override("font_size", 11)
		box.add_child(empty)

	return panel


func _build_hero_list(team: Dictionary, heroes: Array) -> void:
	for hero in heroes:
		var in_team = false
		for slot in team.get("slots", []):
			if slot["hero_id"] == hero["id"]:
				in_team = true
				break
		if in_team:
			continue

		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 54)
		card.add_theme_stylebox_override("panel", _style(Color(0.07, 0.07, 0.14, 0.9), GOLD_DIM, 1, 8))

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		card.add_child(hbox)

		var view := CharacterViewScript.new()
		view.custom_minimum_size = Vector2(44, 44)
		view.style_id = GameManager.get_character_style()
		view.anime_origin = str(hero.get("anime_origin", "Default"))
		view.hero_id = HeroesData.template_id_of(hero)
		hbox.add_child(view)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var name_label = Label.new()
		name_label.text = hero["hero_name"]
		name_label.add_theme_font_size_override("font_size", 13)
		info_vbox.add_child(name_label)

		var sub = Label.new()
		sub.text = "%s • %s" % [hero["hero_class"], Faction.display_name(hero["faction"])]
		sub.add_theme_font_size_override("font_size", 10)
		sub.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		info_vbox.add_child(sub)

		var add_btn = Button.new()
		add_btn.text = "Pasang"
		add_btn.pressed.connect(func(): _on_add_hero(hero["id"]))
		hbox.add_child(add_btn)

		hero_list.add_child(card)

	if heroes.is_empty():
		var empty_box = VBoxContainer.new()
		empty_box.add_theme_constant_override("separation", 6)

		var empty_label = Label.new()
		empty_label.text = "Belum punya hero.\nSummon dulu, hero baru otomatis masuk slot tim kosong."
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_box.add_child(empty_label)

		var summon_btn = Button.new()
		summon_btn.text = "🎁 Summon Hero"
		summon_btn.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/summon.tscn"))
		empty_box.add_child(summon_btn)

		hero_list.add_child(empty_box)


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(6)
	return sb


func _on_add_hero(hero_id: String):
	var team = GameManager.get_team()
	# Find first empty slot
	for slot in team["slots"]:
		if slot["hero_id"] == null:
			for t in GameManager.teams:
				if t["id"] == team["id"]:
					for s in t["slots"]:
						if s["position"] == slot["position"]:
							s["hero_id"] = hero_id
			GameManager.save_game()
			refresh_ui()
			return


func _on_remove(position: int):
	var team = GameManager.get_team()
	for t in GameManager.teams:
		if t["id"] == team["id"]:
			for s in t["slots"]:
				if s["position"] == position:
					s["hero_id"] = null
	GameManager.save_game()
	refresh_ui()
