# scripts/ui/battle_ui.gd
# Battle screen with turn playback: idle/attack/hurt animations, HP bars and
# floating damage numbers on top of the deterministic BattleEngine result.
extends Control

const CharacterViewScript := preload("res://scripts/ui/character_view.gd")

const ITEM_NAMES := {"exp_potion": "EXP Potion", "hero_shard": "Hero Shard"}

const PLAYER_HP_COLOR := Color("46d97a")
const ENEMY_HP_COLOR := Color("ef5350")
const BAR_BG_COLOR := Color(0.12, 0.13, 0.19)
const DEAD_TINT := Color(0.45, 0.42, 0.52, 0.8)

@onready var stage_input: SpinBox = $VBox/StageRow/StageInput
@onready var start_btn: Button = $VBox/StageRow/StartBtn
@onready var skip_btn: Button = $VBox/HeaderRow/SkipBtn
@onready var info_label: Label = $VBox/InfoLabel
@onready var enemy_row: HBoxContainer = $VBox/BattleArea/EnemyRow
@onready var player_row: HBoxContainer = $VBox/BattleArea/PlayerRow
@onready var vs_label: Label = $VBox/BattleArea/VsLabel
@onready var floaters: Control = $VBox/BattleArea/Floaters
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_title: Label = $ResultPanel/VBox/ResultTitle
@onready var result_details: Label = $ResultPanel/VBox/ResultDetails
@onready var rewards_label: Label = $ResultPanel/VBox/RewardsLabel
@onready var ok_btn: Button = $ResultPanel/VBox/OkBtn

var no_team_box: VBoxContainer
var player_units: Array = []
var enemy_units: Array = []
var _playing := false
var _skip := false
var _pending_stage := -1


func _ready() -> void:
	$VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
	start_btn.pressed.connect(_on_start_battle)
	skip_btn.pressed.connect(func(): _skip = true)
	ok_btn.pressed.connect(_on_result_ok)
	stage_input.value = GameManager.progress["current_campaign_stage"]
	stage_input.value_changed.connect(func(_value): _preview_stage())
	_style_result_panel()
	_setup_no_team_notice()
	update_info()
	_preview_stage()


func _style_result_panel() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.08, 0.14, 0.98)
	style.border_color = Color(0.35, 0.40, 0.62)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(18)
	result_panel.add_theme_stylebox_override("panel", style)


## Sets the stage then immediately starts the playback (screenshot tooling / tests).
func auto_battle(stage: int) -> void:
	stage_input.value = stage
	_preview_stage()
	_on_start_battle()


func _setup_no_team_notice() -> void:
	no_team_box = VBoxContainer.new()
	no_team_box.visible = false
	no_team_box.add_theme_constant_override("separation", 6)

	var msg := Label.new()
	msg.text = "⚠️ Tim kamu masih kosong.\nSummon hero dulu, lalu tekan Start Battle lagi."
	msg.add_theme_font_size_override("font_size", 12)
	msg.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	no_team_box.add_child(msg)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	no_team_box.add_child(row)

	var summon_btn := Button.new()
	summon_btn.text = "🎁 Summon Hero"
	summon_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summon_btn.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/summon.tscn"))
	row.add_child(summon_btn)

	var team_btn := Button.new()
	team_btn.text = "👥 Atur Tim"
	team_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	team_btn.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/team.tscn"))
	row.add_child(team_btn)

	$VBox.add_child(no_team_box)
	$VBox.move_child(no_team_box, info_label.get_index() + 1)


func update_info() -> void:
	var heroes := _player_heroes()
	var stage := int(GameManager.progress["current_campaign_stage"])
	info_label.text = "Tim: %d hero • Campaign stage %d" % [heroes.size(), stage]
	if no_team_box:
		no_team_box.visible = heroes.is_empty()


func _player_heroes() -> Array:
	return GameManager.get_player_heroes()


func _enemies_for(stage: int) -> Array:
	return BattleEngine.generate_enemy_team(stage)


func _preview_stage() -> void:
	if _playing:
		return
	_build_arena(_player_heroes(), _enemies_for(int(stage_input.value)))


func _build_arena(heroes: Array, enemies: Array) -> void:
	for child in enemy_row.get_children():
		child.queue_free()
	for child in player_row.get_children():
		child.queue_free()
	for child in floaters.get_children():
		child.queue_free()

	player_units = []
	enemy_units = []

	# Pixel art only scales by whole numbers: 128 = crisp 2x of the 64px sprite.
	# Big teams fall back to 1x so six units still fit the row.
	var unit_px := 128 if maxi(heroes.size(), enemies.size()) <= 5 else 64
	var row_h := float(unit_px + 32)
	enemy_row.offset_bottom = row_h
	player_row.offset_top = -row_h

	_ensure_arena_glow()

	for hero in heroes:
		var unit := _make_unit(hero, BattleEngine.player_max_hp(hero), false, unit_px)
		player_units.append(unit)
		player_row.add_child(unit["box"])

	for enemy in enemies:
		var unit := _make_unit(enemy, BattleEngine.enemy_max_hp(enemy), true, unit_px)
		enemy_units.append(unit)
		enemy_row.add_child(unit["box"])


func _ensure_arena_glow() -> void:
	var arena := enemy_row.get_parent()
	if arena.get_node_or_null("ArenaGlow") != null:
		return
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.30, 0.35, 0.62, 0.30))
	gradient.set_color(1, Color(0.05, 0.06, 0.12, 0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 128
	texture.height = 128
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.55)
	var glow := TextureRect.new()
	glow.name = "ArenaGlow"
	glow.texture = texture
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	arena.add_child(glow)
	arena.move_child(glow, 0)


func _make_unit(hero: Dictionary, max_hp: int, enemy: bool, unit_px: int) -> Dictionary:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(unit_px, unit_px + 30)
	box.add_theme_constant_override("separation", 2)

	var view := CharacterViewScript.new()
	view.custom_minimum_size = Vector2(unit_px, unit_px)
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	view.style_id = GameManager.get_character_style()
	view.anime_origin = str(hero.get("anime_origin", "Enemy" if enemy else "Default"))
	view.hero_id = "" if enemy else HeroesData.template_id_of(hero)
	view.flip_h = enemy
	view.animate_idle = true
	box.add_child(view)

	var full_name := str(hero.get("hero_name", "Hero"))
	var short_name := full_name.split(" ")[0]
	if enemy:
		short_name += " Lv.%d" % int(hero.get("level", 1))

	var name_label := Label.new()
	name_label.text = short_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11 if unit_px >= 128 else 9)
	name_label.add_theme_color_override("font_color", Color(0.75, 0.77, 0.85))
	name_label.clip_text = true
	box.add_child(name_label)

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = max_hp
	bar.value = max_hp
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(unit_px - 8, 7)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bar.add_theme_stylebox_override("background", _bar_style(BAR_BG_COLOR))
	bar.add_theme_stylebox_override("fill", _bar_style(ENEMY_HP_COLOR if enemy else PLAYER_HP_COLOR))
	box.add_child(bar)

	return {"box": box, "view": view, "bar": bar, "hp": float(max_hp), "max": float(max_hp)}


func _bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(3)
	return style


func _on_start_battle() -> void:
	if _playing:
		return

	var stage := int(stage_input.value)
	var heroes := _player_heroes()
	if heroes.is_empty():
		update_info()
		_show_no_team_notice()
		return

	var enemies := _enemies_for(stage)
	var result := BattleEngine.simulate_battle(heroes, enemies)

	_pending_stage = -1
	result_panel.visible = false
	_build_arena(heroes, enemies)
	await _play_battle(result)

	if result["winner"] == "player":
		GameManager.add_gold(result["rewards"]["gold"])
		GameManager.add_exp(result["rewards"]["exp"])
		if stage >= int(GameManager.progress["current_campaign_stage"]):
			GameManager.progress["current_campaign_stage"] = stage + 1
			GameManager.save_game()
			_pending_stage = stage + 1
		result_title.text = "🏆 VICTORY!"
		result_title.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	else:
		result_title.text = "💀 DEFEAT"
		result_title.add_theme_color_override("font_color", Color(0.95, 0.25, 0.3))

	result_details.text = "Rounds: %d\nDamage Dealt: %d\nDamage Taken: %d" % [
		result["rounds"], result["damage_dealt"], result["damage_taken"]
	]

	var rewards_text := ""
	if result["winner"] == "player":
		rewards_text = "💰 %d Gold\n⭐ %d EXP" % [result["rewards"]["gold"], result["rewards"]["exp"]]
		for item in result["rewards"]["items"]:
			rewards_text += "\n📦 " + str(ITEM_NAMES.get(item, item))
	else:
		rewards_text = "Tidak ada reward — naikkan level hero / ganti tim, lalu coba lagi."
	rewards_label.text = rewards_text

	result_panel.visible = true
	update_info()


func _play_battle(result: Dictionary) -> void:
	_playing = true
	_skip = false
	start_btn.disabled = true
	start_btn.text = "⏳ Bertarung..."
	skip_btn.visible = true
	stage_input.editable = false
	vs_label.text = "⚔️"

	var events: Array = result.get("events", [])
	# Keep the whole fight under ~7 seconds no matter how many hits happen.
	var delay := clampf(7.0 / maxf(1.0, float(events.size())), 0.04, 0.30)

	for event in events:
		if _skip:
			break
		await _play_event(event, delay)

	_sync_bars(result)
	_show_victory(result)

	skip_btn.visible = false
	start_btn.disabled = false
	start_btn.text = "⚔️ Start Battle"
	stage_input.editable = true
	vs_label.text = "VS"
	_playing = false


func _play_event(event: Dictionary, delay: float) -> void:
	var attacker_side := str(event["side"])
	var actors: Array = player_units if attacker_side == "player" else enemy_units
	var targets: Array = enemy_units if attacker_side == "player" else player_units
	vs_label.text = "ROUND %d" % int(event.get("round", 1))
	var actor_index := int(event["actor"])
	var target_index := int(event["target"])
	if actor_index >= actors.size() or target_index >= targets.size():
		return

	var actor: Dictionary = actors[actor_index]
	var target: Dictionary = targets[target_index]
	if float(actor["hp"]) <= 0.0:
		return

	actor["view"].play("attack")
	await get_tree().create_timer(delay * 0.4).timeout

	target["hp"] = maxf(0.0, float(target["hp"]) - float(event["damage"]))
	(target["bar"] as ProgressBar).value = target["hp"]
	target["view"].play("hurt")
	_spawn_damage(target, int(event["damage"]), bool(event["crit"]), float(event["mult"]))

	if bool(event["killed"]):
		target["hp"] = 0.0
		(target["bar"] as ProgressBar).value = 0
		(target["view"] as Control).modulate = DEAD_TINT

	await get_tree().create_timer(delay * 0.6).timeout


func _spawn_damage(target: Dictionary, damage: int, crit: bool, mult: float) -> void:
	var view: Control = target["view"]
	var label := Label.new()
	label.text = str(damage) + ("!" if crit else "")
	label.add_theme_font_size_override("font_size", 24 if crit else 16)
	var color := Color(1.0, 0.55, 0.2) if crit else Color(1, 1, 1)
	if mult >= 3.0 and not crit:
		color = Color(1.0, 0.86, 0.35)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(48, 22)

	var center := view.get_global_rect().get_center() - floaters.get_global_rect().position
	# Jitter so several hits in a row stay readable instead of stacking.
	label.position = center - Vector2(24, 12) + Vector2(randf_range(-16.0, 16.0), randf_range(-6.0, 6.0))
	label.size = Vector2(48, 22)
	floaters.add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 46.0, 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.35).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)


func _sync_bars(result: Dictionary) -> void:
	var player_hp: Array = result.get("player_hp", [])
	var enemy_hp: Array = result.get("enemy_hp", [])
	for i in range(mini(player_units.size(), player_hp.size())):
		var unit: Dictionary = player_units[i]
		unit["hp"] = maxf(0.0, float(player_hp[i]))
		(unit["bar"] as ProgressBar).value = unit["hp"]
		if float(unit["hp"]) <= 0.0:
			(unit["view"] as Control).modulate = DEAD_TINT
	for i in range(mini(enemy_units.size(), enemy_hp.size())):
		var unit: Dictionary = enemy_units[i]
		unit["hp"] = maxf(0.0, float(enemy_hp[i]))
		(unit["bar"] as ProgressBar).value = unit["hp"]
		if float(unit["hp"]) <= 0.0:
			(unit["view"] as Control).modulate = DEAD_TINT


func _show_victory(result: Dictionary) -> void:
	var winners: Array = player_units if result["winner"] == "player" else enemy_units
	for unit in winners:
		if float(unit["hp"]) > 0.0:
			unit["view"].play("victory")


func _show_no_team_notice() -> void:
	no_team_box.visible = true
	no_team_box.modulate = Color(1.8, 1.8, 1.8)
	var tween := create_tween()
	tween.tween_property(no_team_box, "modulate", Color.WHITE, 0.4)


func _on_result_ok() -> void:
	result_panel.visible = false
	update_info()
	if _pending_stage > 0 and int(stage_input.value) != _pending_stage:
		var next := _pending_stage
		_pending_stage = -1
		stage_input.value = next  # value_changed refreshes the arena
		return
	_pending_stage = -1
	_preview_stage()
