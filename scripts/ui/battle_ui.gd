# scripts/ui/battle_ui.gd
# Battle screen with turn playback: idle/attack/hurt animations, HP bars and
# floating damage numbers on top of the deterministic BattleEngine result.
extends Control

const CharacterViewScript := preload("res://scripts/ui/character_view.gd")
const CutinBackdropScript := preload("res://scripts/ui/cutin_backdrop.gd")

const ITEM_NAMES := {"exp_potion": "EXP Potion", "hero_shard": "Hero Shard", "courage_essence": "Courage Essence", "soul_crystal": "Soul Crystal"}

const ENERGY_COLOR := Color("f7b733")
const ENEMY_ENERGY_COLOR := Color("b06cff")

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
var _cut_in_count := 0


func _ready() -> void:
	var mode := _mode()
	var back := "res://scenes/main.tscn" if mode == "campaign" else "res://scenes/ui/pve.tscn"
	$VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene(back))
	start_btn.pressed.connect(_on_start_battle)
	skip_btn.pressed.connect(func(): _skip = true)
	ok_btn.pressed.connect(_on_result_ok)
	stage_input.value = GameManager.pve_floor(mode)
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
	var mode := _mode()
	var mode_name := str(GameConfig.pve_mode(mode).get("name", "Campaign"))
	info_label.text = "Tim: %d hero • %s %d" % [heroes.size(), mode_name, GameManager.pve_floor(mode)]
	if no_team_box:
		no_team_box.visible = heroes.is_empty()


func _mode() -> String:
	return GameManager.pending_pve_mode


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

	# Ultimate gauge: fills with each action, empties when the ultimate fires.
	var energy := ProgressBar.new()
	energy.min_value = 0
	energy.max_value = BattleEngine.ENERGY_MAX
	energy.value = 0
	energy.show_percentage = false
	energy.custom_minimum_size = Vector2(unit_px - 16, 4)
	energy.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	energy.add_theme_stylebox_override("background", _bar_style(BAR_BG_COLOR))
	energy.add_theme_stylebox_override(
		"fill", _bar_style(ENEMY_ENERGY_COLOR if enemy else ENERGY_COLOR)
	)
	box.add_child(energy)

	return {
		"box": box,
		"view": view,
		"bar": bar,
		"energy_bar": energy,
		"hero": hero,
		"enemy": enemy,
		"hp": float(max_hp),
		"max": float(max_hp),
	}


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
		var mode := _mode()
		var gold_gain := int(round(float(result["rewards"]["gold"]) * GameConfig.pve_gold_mult(mode)))
		GameManager.add_gold(gold_gain)
		GameManager.add_exp(result["rewards"]["exp"])
		var mats: Dictionary = result["rewards"].get("materials", {})
		for key in mats:
			GameManager.add_progress(str(key), int(mats[key]))
		var bonus: Dictionary = GameConfig.pve_bonus(mode)
		for key in bonus:
			GameManager.add_progress(str(key), int(bonus[key]))
		_pending_stage = GameManager.advance_pve(mode, stage)
		result_title.text = "🏆 VICTORY!"
		result_title.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	else:
		result_title.text = "💀 DEFEAT"
		result_title.add_theme_color_override("font_color", Color(0.95, 0.25, 0.3))

	result_details.text = "Rounds: %d\nDamage Dealt: %d\nDamage Taken: %d\nUltimates: %d" % [
		result["rounds"], result["damage_dealt"], result["damage_taken"], result.get("ultimates", 0)
	]

	var rewards_text := ""
	if result["winner"] == "player":
		var mode := _mode()
		var gold_gain := int(round(float(result["rewards"]["gold"]) * GameConfig.pve_gold_mult(mode)))
		rewards_text = "💰 %d Gold\n⭐ %d EXP" % [gold_gain, result["rewards"]["exp"]]
		for item in result["rewards"]["items"]:
			rewards_text += "\n📦 " + str(ITEM_NAMES.get(item, item))
		var mats_display: Dictionary = result["rewards"].get("materials", {})
		for key in mats_display:
			rewards_text += "\n💫 %d %s" % [int(mats_display[key]), str(ITEM_NAMES.get(key, key))]
		var bonus_display: Dictionary = GameConfig.pve_bonus(mode)
		for key in bonus_display:
			rewards_text += "\n🎁 %d %s" % [int(bonus_display[key]), str(ITEM_NAMES.get(key, key))]
	else:
		rewards_text = "Tidak ada reward — naikkan level hero / ganti tim, lalu coba lagi."
	rewards_label.text = rewards_text

	result_panel.visible = true
	update_info()


func _play_battle(result: Dictionary) -> void:
	_playing = true
	_skip = false
	_cut_in_count = 0
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

	var is_ult := bool(event.get("ultimate", false))
	var energy_bar := actor.get("energy_bar") as ProgressBar
	if is_ult:
		if energy_bar != null:
			energy_bar.value = BattleEngine.ENERGY_MAX
		await _play_cut_in(actor, event)

	actor["view"].play("attack")
	await get_tree().create_timer(delay * 0.4).timeout

	target["hp"] = maxf(0.0, float(target["hp"]) - float(event["damage"]))
	(target["bar"] as ProgressBar).value = target["hp"]
	target["view"].play("hurt")
	_spawn_damage(target, int(event["damage"]), bool(event["crit"]), float(event["mult"]), is_ult)
	if energy_bar != null:
		energy_bar.value = float(event.get("energy_after", 0))

	if bool(event["killed"]):
		target["hp"] = 0.0
		(target["bar"] as ProgressBar).value = 0
		(target["view"] as Control).modulate = DEAD_TINT

	await get_tree().create_timer(delay * 0.6).timeout


## Full-screen ultimate cut-in: dim, diagonal banner, zoomed hero, skill name.
## Enemy ultimates use a violet accent. After the first three full cut-ins the
## timing shortens so long fights do not drag.
func _play_cut_in(actor: Dictionary, event: Dictionary) -> void:
	if _skip:
		return
	_cut_in_count += 1
	var quick := _cut_in_count > 3
	var skill_name := str(event.get("skill", "ULTIMATE"))
	var enemy := bool(actor.get("enemy", false))
	var accent := ENEMY_ENERGY_COLOR if enemy else ENERGY_COLOR
	var hero: Dictionary = actor.get("hero", {})
	var screen := get_viewport_rect().size

	var layer := Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.z_index = 20
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(layer)

	# Illustrated backdrop (Canva art if available, otherwise procedural).
	var backdrop := CutinBackdropScript.new()
	backdrop.hero_id = "" if enemy else HeroesData.template_id_of(hero)
	backdrop.anime_origin = str(hero.get("anime_origin", "Enemy" if enemy else "Default"))
	backdrop.enemy = enemy
	backdrop.accent = accent
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(backdrop)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.06, 0.0)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)

	# Diagonal banner behind the name (two stacked bars).
	var bar := ColorRect.new()
	bar.color = Color(accent.r, accent.g, accent.b, 0.88)
	bar.size = Vector2(screen.x * 1.5, 20)
	bar.position = Vector2(-screen.x * 0.2, screen.y * 0.305)
	bar.rotation = -0.10
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bar)
	var bar2 := ColorRect.new()
	bar2.color = Color(accent.r, accent.g, accent.b, 0.45)
	bar2.size = Vector2(screen.x * 1.5, 6)
	bar2.position = Vector2(-screen.x * 0.2, screen.y * 0.352)
	bar2.rotation = -0.10
	bar2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bar2)

	# Zoomed hero portrait (integer 2x/3x so pixel art stays crisp).
	var side_px := 192 if screen.x >= 480 else 128
	var view := CharacterViewScript.new()
	view.custom_minimum_size = Vector2(side_px, side_px)
	view.size = Vector2(side_px, side_px)
	view.style_id = GameManager.get_character_style()
	view.anime_origin = str(hero.get("anime_origin", "Enemy" if enemy else "Default"))
	view.hero_id = "" if enemy else HeroesData.template_id_of(hero)
	view.flip_h = enemy
	view.position = Vector2(-side_px, screen.y * 0.44 - side_px * 0.5)
	view.play("attack")
	layer.add_child(view)

	var caption := Label.new()
	caption.text = "ULTIMATE"
	caption.add_theme_font_size_override("font_size", 13)
	caption.add_theme_color_override("font_color", accent)
	caption.add_theme_constant_override("outline_size", 3)
	caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	caption.position = Vector2(screen.x + 60.0, screen.y * 0.332)
	layer.add_child(caption)

	var name_label := Label.new()
	name_label.text = skill_name.to_upper()
	name_label.add_theme_font_size_override("font_size", 30 if screen.x >= 480 else 24)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	name_label.add_theme_constant_override("outline_size", 7)
	name_label.add_theme_color_override(
		"font_outline_color", Color(accent.r * 0.35, accent.g * 0.35, accent.b * 0.35, 1.0)
	)
	name_label.position = Vector2(screen.x + 60.0, screen.y * 0.365)
	layer.add_child(name_label)

	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(flash)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(dim, "color:a", 0.40, 0.12)
	tween.tween_property(view, "position:x", screen.x * 0.08, 0.20)
	tween.tween_property(caption, "position:x", screen.x * 0.44, 0.22)
	tween.tween_property(name_label, "position:x", screen.x * 0.44, 0.22)
	await get_tree().create_timer(0.26 if quick else 0.34).timeout

	flash.color.a = 0.45
	var fade := create_tween()
	fade.tween_property(flash, "color:a", 0.0, 0.18)
	await get_tree().create_timer(0.16 if quick else 0.22).timeout

	var out_tween := create_tween()
	out_tween.tween_property(layer, "modulate:a", 0.0, 0.16)
	await get_tree().create_timer(0.16).timeout
	layer.queue_free()


## Shows the cut-in for the first team member (screenshot tooling / demos).
func show_ultimate_preview(actor_index: int = 0) -> void:
	_preview_stage()
	await get_tree().process_frame
	if player_units.is_empty():
		return
	var unit: Dictionary = player_units[clampi(actor_index, 0, player_units.size() - 1)]
	var ult := BattleEngine.ultimate_of(unit["hero"])
	var energy := unit.get("energy_bar") as ProgressBar
	if energy != null:
		energy.value = BattleEngine.ENERGY_MAX
	await _play_cut_in(unit, {"side": "player", "skill": ult["name"]})


func _spawn_damage(
	target: Dictionary, damage: int, crit: bool, mult: float, is_ult: bool = false
) -> void:
	var view: Control = target["view"]
	var label := Label.new()
	label.text = str(damage) + ("!" if crit else "")
	var font_size := 16
	if crit:
		font_size = 24
	if is_ult:
		font_size = 34
	label.add_theme_font_size_override("font_size", font_size)
	var color := Color(1.0, 0.55, 0.2) if crit else Color(1, 1, 1)
	if mult >= 3.0 and not crit:
		color = Color(1.0, 0.86, 0.35)
	if is_ult:
		color = Color(1.0, 0.80, 0.28)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 5 if is_ult else 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var box_w := 72.0 if is_ult else 48.0
	var box_h := 30.0 if is_ult else 22.0
	label.custom_minimum_size = Vector2(box_w, box_h)

	var center := view.get_global_rect().get_center() - floaters.get_global_rect().position
	# Jitter so several hits in a row stay readable instead of stacking.
	label.position = center - Vector2(box_w * 0.5, box_h * 0.5) + Vector2(
		randf_range(-16.0, 16.0), randf_range(-6.0, 6.0)
	)
	label.size = Vector2(box_w, box_h)
	floaters.add_child(label)

	var rise := 66.0 if is_ult else 46.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - rise, 0.8 if is_ult else 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.45)
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
