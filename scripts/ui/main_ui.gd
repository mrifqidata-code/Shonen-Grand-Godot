# scripts/ui/main_ui.gd
extends Control

const CharacterViewScript := preload("res://scripts/ui/character_view.gd")

@onready var gold_label: Label = $VBox/Header/HBox/Resources/GoldRow/GoldLabel
@onready var dia_label: Label = $VBox/Header/HBox/Resources/DiaRow/DiaLabel
@onready var ticket_label: Label = $VBox/Header/HBox/Resources/TicketRow/TicketLabel
@onready var avatar_label: Label = $VBox/Header/HBox/AvatarBox/Avatar
@onready var team_preview: HBoxContainer = $VBox/Content/TeamPreview

func _ready() -> void:
	$VBox/Content/QuickActions/BattleBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/battle.tscn"))
	$VBox/Content/QuickActions/SummonBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/summon.tscn"))
	$VBox/Content/MenuButtons/BtnHeroes.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/heroes.tscn"))
	$VBox/Content/MenuButtons/BtnTeam.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/team.tscn"))
	$VBox/Content/MenuButtons/BtnInventory.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/inventory.tscn"))
	$VBox/Content/MenuButtons/BtnStyle.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/character_style.tscn"))
	$VBox/Content/MenuButtons/BtnCanva.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/canva_generator.tscn"))

	$VBox/BottomNav/NavHome.pressed.connect(func(): pass)
	$VBox/BottomNav/NavBattle.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/battle.tscn"))
	$VBox/BottomNav/NavHeroes.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/heroes.tscn"))
	$VBox/BottomNav/NavSummon.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/summon.tscn"))
	$VBox/BottomNav/NavMore.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/inventory.tscn"))

	_refresh()


func _refresh() -> void:
	avatar_label.text = "Lv.%d" % int(GameManager.progress.get("level", 1))
	gold_label.text = _fmt(GameManager.progress.get("gold", 0))
	dia_label.text = _fmt(GameManager.progress.get("diamonds", 0))
	ticket_label.text = _fmt(GameManager.progress.get("tickets", 0))

	for child in team_preview.get_children():
		child.queue_free()
	var heroes := GameManager.get_player_heroes()
	if heroes.is_empty():
		var empty := Label.new()
		empty.text = "Belum ada hero — summon dulu"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		team_preview.add_child(empty)
		return
	for hero in heroes.slice(0, 5):
		var view := CharacterViewScript.new()
		view.custom_minimum_size = Vector2(56, 56)
		view.style_id = GameManager.get_character_style()
		view.anime_origin = str(hero.get("anime_origin", "Default"))
		view.hero_id = str(hero.get("template_id", ""))
		team_preview.add_child(view)


func _fmt(v) -> String:
	var n := int(v)
	if n >= 1000000:
		return "%.1fM" % (n / 1000000.0)
	if n >= 1000:
		return "%.1fK" % (n / 1000.0)
	return str(n)
