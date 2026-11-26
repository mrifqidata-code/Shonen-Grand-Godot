# scripts/ui/gear_ui.gd
# Gear screen: equip/upgrade/craft gear, glyph lottery, rune crafting. Stats
# stack onto the hero via GameManager.enrich_hero (applied in battle).
extends Control

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")

@onready var hero_option: OptionButton = $VBox/HeroRow/HeroOption
@onready var content: VBoxContainer = $VBox/Scroll/Content
@onready var status_label: Label = $VBox/StatusLabel

var _hero_ids: Array = []


func _ready() -> void:
	$VBox/HeaderRow/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	hero_option.item_selected.connect(func(_i): _build())
	_refresh_heroes()
	_build()


func _refresh_heroes() -> void:
	hero_option.clear()
	_hero_ids.clear()
	for hero in GameManager.get_player_heroes():
		_hero_ids.append(str(hero.get("id", "")))
		hero_option.add_item(str(hero.get("hero_name", "Hero")), _hero_ids.size() - 1)
	if _hero_ids.is_empty():
		hero_option.add_item("(no hero)", -1)


func _selected_hero_id() -> String:
	if _hero_ids.is_empty():
		return ""
	var idx := hero_option.selected
	if idx < 0 or idx >= _hero_ids.size():
		return ""
	return str(_hero_ids[idx])


func _build() -> void:
	for child in content.get_children():
		child.queue_free()
	var hid := _selected_hero_id()
	if hid.is_empty():
		var empty := Label.new()
		empty.text = "Summon hero dulu."
		content.add_child(empty)
		return
	var hero := GameManager.get_hero_by_id(hid)
	if hero.is_empty():
		return

	# Equip slots.
	var slot_title := Label.new()
	slot_title.text = "Equip Slots"
	slot_title.add_theme_font_size_override("font_size", 16)
	slot_title.add_theme_color_override("font_color", GOLD)
	content.add_child(slot_title)

	var eq: Dictionary = GameManager.gear_equipped.get(hid, {})
	for slot in GameConfig.EQUIP_SLOTS:
		content.add_child(_slot_card(hid, slot, str(eq.get(slot, ""))))

	# Glyphs.
	var gtitle := Label.new()
	gtitle.text = "Glyphs (lottery)"
	gtitle.add_theme_font_size_override("font_size", 16)
	gtitle.add_theme_color_override("font_color", GOLD)
	content.add_child(gtitle)
	var garr: Array = GameManager.glyphs.get(hid, [])
	for i in range(GameConfig.GLYPH_COUNT):
		content.add_child(_glyph_card(hid, i, str(garr[i]) if i < garr.size() else ""))

	var gbtn := Button.new()
	gbtn.text = "Lottery Glyph (%d💰)" % GameConfig.GLYPH_LOTTERY_COST
	gbtn.custom_minimum_size = Vector2(0, 40)
	gbtn.pressed.connect(_on_glyph_lottery.bind(hid))
	content.add_child(gbtn)

	# Runes.
	var rtitle := Label.new()
	rtitle.text = "Runes"
	rtitle.add_theme_font_size_override("font_size", 16)
	rtitle.add_theme_color_override("font_color", GOLD)
	content.add_child(rtitle)
	var rarr: Array = GameManager.runes.get(hid, [])
	for i in range(GameConfig.RUNE_COUNT):
		content.add_child(_rune_card(hid, i, str(rarr[i]) if i < rarr.size() else ""))

	# Craft gear.
	var ctitle := Label.new()
	ctitle.text = "Craft Gear"
	ctitle.add_theme_font_size_override("font_size", 16)
	ctitle.add_theme_color_override("font_color", GOLD)
	content.add_child(ctitle)
	var craft_row := HBoxContainer.new()
	craft_row.add_theme_constant_override("separation", 6)
	content.add_child(craft_row)
	for slot in GameConfig.EQUIP_SLOTS:
		var cb := Button.new()
		cb.text = "Craft %s" % str(GameConfig.EQUIP_SLOT_LABELS[slot]).split(" ")[1]
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.custom_minimum_size = Vector2(0, 36)
		cb.pressed.connect(_on_craft.bind(slot))
		craft_row.add_child(cb)

	# Inventory summary.
	var inv_title := Label.new()
	inv_title.text = "Gear Inventory (%d)" % GameManager.gear_inventory.size()
	inv_title.add_theme_font_size_override("font_size", 14)
	inv_title.add_theme_color_override("font_color", Color(0.75, 0.78, 0.88))
	content.add_child(inv_title)


func _slot_card(hid: String, slot: String, item_id: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 8))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	card.add_child(row)

	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var item := GameManager._gear_by_id(item_id) if not item_id.is_empty() else {}
	if item.is_empty():
		label.text = "%s: (kosong)" % str(GameConfig.EQUIP_SLOT_LABELS[slot])
		label.add_theme_color_override("font_color", Color(0.5, 0.52, 0.62))
	else:
		label.text = "%s: %s %s Lv.%d (+%d ATK)" % [
			str(GameConfig.EQUIP_SLOT_LABELS[slot]),
			item["rarity"], item["slot"], int(item["level"]), int(item["atk"])
		]
		label.add_theme_color_override("font_color", GOLD)
	row.add_child(label)

	if not item.is_empty():
		var up := Button.new()
		up.text = "Up"
		up.custom_minimum_size = Vector2(52, 34)
		up.pressed.connect(_on_upgrade.bind(item_id))
		row.add_child(up)
		var uneq := Button.new()
		uneq.text = "Unequip"
		uneq.custom_minimum_size = Vector2(74, 34)
		uneq.pressed.connect(_on_unequip.bind(hid, slot))
		row.add_child(uneq)
	else:
		# Offer equip from inventory matching slot.
		var inv_items := GameManager.gear_inventory.filter(func(it): return str(it.get("slot", "")) == slot)
		if not inv_items.is_empty():
			var eq := Button.new()
			eq.text = "Equip"
			eq.custom_minimum_size = Vector2(74, 34)
			eq.pressed.connect(_on_equip_picker.bind(hid, slot))
			row.add_child(eq)
	return card


func _glyph_card(hid: String, slot: int, glyph_id: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 8))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	card.add_child(row)
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if glyph_id.is_empty():
		label.text = "Glyph %d: (kosong)" % (slot + 1)
		label.add_theme_color_override("font_color", Color(0.5, 0.52, 0.62))
	else:
		var gname := glyph_id
		for _gi in range(GameConfig.GLYPHS.size()):
			var gl: Dictionary = GameConfig.GLYPHS[_gi]
			if str(gl["id"]) == glyph_id:
				gname = str(gl["name"])
		label.text = "Glyph %d: %s" % [slot + 1, gname]
		label.add_theme_color_override("font_color", GOLD)
	row.add_child(label)
	var clear := Button.new()
	clear.text = "Clear"
	clear.custom_minimum_size = Vector2(60, 30)
	clear.pressed.connect(func(): GameManager.set_glyph(hid, slot, ""); _build())
	row.add_child(clear)
	return card


func _rune_card(hid: String, slot: int, rune_id: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 8))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	card.add_child(row)
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if rune_id.is_empty():
		label.text = "Rune %d: (kosong)" % (slot + 1)
		label.add_theme_color_override("font_color", Color(0.5, 0.52, 0.62))
	else:
		var rname := rune_id
		for _ri in range(GameConfig.RUNES.size()):
			var ru: Dictionary = GameConfig.RUNES[_ri]
			if str(ru["id"]) == rune_id:
				rname = "%s (%s)" % [ru["name"], ru["desc"]]
		label.text = "Rune %d: %s" % [slot + 1, rname]
		label.add_theme_color_override("font_color", GOLD)
	row.add_child(label)
	var clear := Button.new()
	clear.text = "Clear"
	clear.custom_minimum_size = Vector2(60, 30)
	clear.pressed.connect(func(): GameManager.set_rune(hid, slot, ""); _build())
	row.add_child(clear)
	return card


func _on_upgrade(item_id: String) -> void:
	if GameManager.upgrade_gear(item_id):
		status_label.text = "✅ Gear di-upgrade."
		status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
	else:
		status_label.text = "❌ Gold tidak cukup / sudah MAX."
		status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
	_build()


func _on_unequip(hid: String, slot: String) -> void:
	GameManager.unequip_gear(hid, slot)
	status_label.text = "Lepas gear."
	_build()


func _on_equip_picker(hid: String, slot: String) -> void:
	var inv_items := GameManager.gear_inventory.filter(func(it): return str(it.get("slot", "")) == slot)
	if inv_items.is_empty():
		return
	# Equip the first matching inventory item.
	var item_id := str(inv_items[0].get("id", ""))
	if GameManager.equip_gear(hid, slot, item_id):
		status_label.text = "✅ Gear dipasang."
		status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
	_build()


func _on_craft(slot: String) -> void:
	var item := GameManager.craft_gear(slot)
	status_label.text = "🔨 Crafted %s %s Lv.1" % [item["rarity"], slot]
	status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
	_build()


func _on_glyph_lottery(hid: String) -> void:
	if not GameManager.spend_gold(GameConfig.GLYPH_LOTTERY_COST):
		status_label.text = "❌ Gold tidak cukup."
		status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
		return
	var gl: Dictionary = GameConfig.GLYPHS[randi() % GameConfig.GLYPHS.size()]
	# Find first empty glyph slot.
	var arr: Array = GameManager.glyphs.get(hid, [])
	var slot := -1
	for i in range(arr.size()):
		if str(arr[i]).is_empty():
			slot = i
			break
	if slot == -1:
		slot = randi() % arr.size()
	GameManager.set_glyph(hid, slot, str(gl["id"]))
	status_label.text = "✨ Dapat %s" % gl["name"]
	status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
	_build()


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(6)
	return sb
