# scripts/ui/pve_ui.gd
# PvE hub: Campaign, Monster Tower, Maze and Mountain Trial. Each mode keeps its
# own floor counter; entering a mode sets GameManager.pending_pve_mode and opens
# the battle scene, which reads the mode for enemies, rewards and progression.
extends Control

const GOLD := Color("d8b24a")
const GOLD_DIM := Color("8a6f1a")

@onready var mode_list: VBoxContainer = $VBox/Scroll/ModeList
@onready var status_label: Label = $VBox/StatusLabel


func _ready() -> void:
	$VBox/HeaderRow/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	_build()


func _build() -> void:
	for child in mode_list.get_children():
		child.queue_free()
	for mode in GameConfig.PVE_MODES:
		mode_list.add_child(_mode_card(mode))


func _mode_card(mode: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 118)
	card.add_theme_stylebox_override("panel", _style(Color(0.08, 0.08, 0.16, 0.94), GOLD_DIM, 1, 12))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)

	var icon := Label.new()
	icon.text = str(mode["icon"])
	icon.add_theme_font_size_override("font_size", 40)
	icon.custom_minimum_size = Vector2(64, 0)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(icon)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)

	var name_label := Label.new()
	name_label.text = str(mode["name"])
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", GOLD)
	info.add_child(name_label)

	var desc := Label.new()
	desc.text = str(mode["desc"])
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.68, 0.70, 0.78))
	info.add_child(desc)

	var floor := Label.new()
	floor.text = "Floor / Stage: %d" % GameManager.pve_floor(str(mode["id"]))
	floor.add_theme_font_size_override("font_size", 11)
	floor.add_theme_color_override("font_color", Color(0.85, 0.88, 0.98))
	info.add_child(floor)

	var enter := Button.new()
	enter.text = "Masuk"
	enter.custom_minimum_size = Vector2(90, 44)
	enter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	enter.pressed.connect(_enter.bind(str(mode["id"])))
	row.add_child(enter)

	return card


func _enter(mode_id: String) -> void:
	GameManager.pve_set_mode(mode_id, GameManager.pve_floor(mode_id))
	status_label.text = "Memuat %s..." % GameConfig.pve_mode(mode_id).get("name", mode_id)
	SceneManager.change_scene("res://scenes/ui/battle.tscn")


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(10)
	return sb