# scripts/ui/submenu_ui.gd
# Reusable Twilight-style secondary screen. Renders the menu selected by
# GameManager.pending_menu (see GameConfig.SUBMENUS): a header, a subtitle and a
# list of feature cards, each of which may open another screen.
extends Control

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")

const SCENES := {
	"summon": "res://scenes/ui/summon.tscn",
	"heroes": "res://scenes/ui/heroes.tscn",
	"team": "res://scenes/ui/team.tscn",
	"battle": "res://scenes/ui/battle.tscn",
	"bag": "res://scenes/ui/inventory.tscn",
	"store": "res://scenes/ui/store.tscn",
	"style": "res://scenes/ui/character_style.tscn",
	"pve": "res://scenes/ui/pve.tscn",
	"home": "res://scenes/main.tscn",
	"submenu": "res://scenes/ui/submenu.tscn",
}

@onready var title_label: Label = $VBox/HeaderRow/Title
@onready var subtitle_label: Label = $VBox/SubTitle
@onready var entry_list: VBoxContainer = $VBox/Scroll/EntryList
@onready var status_label: Label = $VBox/StatusLabel


func _ready() -> void:
	$VBox/HeaderRow/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	_build()


## Lets the screenshot tooling open a specific menu without touching the save.
func preview(menu_id: String) -> void:
	GameManager.pending_menu = menu_id
	_build()


func _build() -> void:
	var menu := GameConfig.submenu(GameManager.pending_menu)
	if menu.is_empty():
		title_label.text = "Menu"
		subtitle_label.text = "Belum ada konten."
		return
	title_label.text = str(menu.get("title", "Menu"))
	subtitle_label.text = str(menu.get("subtitle", ""))
	for entry in menu.get("entries", []):
		entry_list.add_child(_entry_card(entry))


func _entry_card(entry: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 74)
	card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 10))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)

	var icon := Label.new()
	icon.text = str(entry.get("icon", "•"))
	icon.add_theme_font_size_override("font_size", 28)
	icon.custom_minimum_size = Vector2(48, 0)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(icon)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 1)
	row.add_child(info)

	var name_label := Label.new()
	name_label.text = str(entry.get("name", "Fitur"))
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", GOLD)
	info.add_child(name_label)

	var desc := Label.new()
	desc.text = str(entry.get("desc", ""))
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.66, 0.69, 0.78))
	info.add_child(desc)

	if str(entry.get("action", "")) == "daily":
		var claim := Button.new()
		claim.text = "Klaim" if GameManager.can_claim_daily() else "Sudah"
		claim.disabled = not GameManager.can_claim_daily()
		claim.custom_minimum_size = Vector2(84, 40)
		claim.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		claim.pressed.connect(_on_claim_daily.bind(claim))
		row.add_child(claim)
	else:
		var open := Button.new()
		open.text = "Buka"
		open.custom_minimum_size = Vector2(84, 40)
		open.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		open.pressed.connect(_go.bind(str(entry.get("goto", ""))))
		row.add_child(open)

	return card


func _go(key: String) -> void:
	if key.is_empty():
		status_label.text = "Fitur ini menyusul."
		return
	if key.begins_with("menu:"):
		GameManager.pending_menu = key.substr(5)
		SceneManager.change_scene(SCENES["submenu"])
		return
	if SCENES.has(key):
		SceneManager.change_scene(SCENES[key])
	else:
		status_label.text = "Fitur ini menyusul."


func _on_claim_daily(button: Button) -> void:
	if GameManager.claim_daily():
		status_label.text = "📅 Daily reward diklaim!"
		status_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.6))
		button.text = "Sudah"
		button.disabled = true


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(8)
	return sb
