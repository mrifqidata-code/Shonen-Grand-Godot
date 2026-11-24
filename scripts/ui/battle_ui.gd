# scripts/ui/battle_ui.gd
extends Control

const CharacterViewScript := preload("res://scripts/ui/character_view.gd")

@onready var stage_input = $VBox/StageRow/StageInput
@onready var start_btn = $VBox/StageRow/StartBtn
@onready var info_label = $VBox/InfoLabel
@onready var result_panel = $VBox/ResultPanel
@onready var result_title = $VBox/ResultPanel/VBox/ResultTitle
@onready var result_details = $VBox/ResultPanel/VBox/ResultDetails
@onready var rewards_label = $VBox/ResultPanel/VBox/RewardsLabel
@onready var ok_btn = $VBox/ResultPanel/VBox/OkBtn
@onready var enemy_grid = $VBox/EnemyScroll/EnemyGrid

var team_row: HBoxContainer
var team_title: Label

func _ready():
    $VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    start_btn.pressed.connect(_on_start_battle)
    ok_btn.pressed.connect(func(): result_panel.visible = false)
    stage_input.value = GameManager.progress["current_campaign_stage"]
    _setup_team_row()
    update_info()
    refresh_enemy_preview()

func _setup_team_row():
    # "Tim Kamu" strip right under the info label, built in code so the scene
    # file stays simple. Uses the display style chosen in Gaya Karakter.
    team_title = Label.new()
    team_title.text = "Tim Kamu"
    team_title.add_theme_font_size_override("font_size", 12)
    team_title.add_theme_color_override("font_color", Color(0.7, 0.74, 0.86))
    $VBox.add_child(team_title)

    team_row = HBoxContainer.new()
    team_row.add_theme_constant_override("separation", 8)
    $VBox.add_child(team_row)

    var info_index = $VBox/InfoLabel.get_index()
    $VBox.move_child(team_title, info_index + 1)
    $VBox.move_child(team_row, info_index + 2)

func update_info():
    var heroes = GameManager.get_player_heroes()
    info_label.text = "Tim: %d hero • Stage saat ini: %d" % [heroes.size(), GameManager.progress["current_campaign_stage"]]
    _refresh_team_row(heroes)

func _refresh_team_row(heroes: Array):
    for child in team_row.get_children():
        child.queue_free()

    if heroes.is_empty():
        var empty = Label.new()
        empty.text = "Tim kosong — atur dulu di menu Team."
        empty.add_theme_font_size_override("font_size", 11)
        empty.add_theme_color_override("font_color", Color(0.6, 0.6, 0.66))
        team_row.add_child(empty)
        return

    for hero in heroes:
        var col = VBoxContainer.new()
        col.add_theme_constant_override("separation", 0)

        var view = CharacterViewScript.new()
        view.custom_minimum_size = Vector2(64, 64)
        view.style_id = GameManager.get_character_style()
        view.anime_origin = str(hero.get("anime_origin", "Default"))
        col.add_child(view)

        var name_label = Label.new()
        var full_name = str(hero.get("hero_name", "Hero"))
        name_label.text = full_name.split(" ")[0]
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 9)
        name_label.add_theme_color_override("font_color", Color(0.75, 0.77, 0.85))
        col.add_child(name_label)

        team_row.add_child(col)

func refresh_enemy_preview():
    for child in enemy_grid.get_children():
        child.queue_free()
    var stage = int(stage_input.value)
    var enemies = BattleEngine.generate_enemy_team(stage)
    for e in enemies:
        var panel = PanelContainer.new()
        panel.custom_minimum_size = Vector2(0, 68)

        var row = HBoxContainer.new()
        row.add_theme_constant_override("separation", 8)
        panel.add_child(row)

        var view = CharacterViewScript.new()
        view.custom_minimum_size = Vector2(64, 64)
        view.style_id = GameManager.get_character_style()
        view.anime_origin = str(e.get("anime_origin", "Enemy"))
        view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        row.add_child(view)

        var vbox = VBoxContainer.new()
        vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(vbox)

        var name_l = Label.new()
        name_l.text = e["hero_name"]
        name_l.add_theme_font_size_override("font_size", 12)
        vbox.add_child(name_l)
        var info = Label.new()
        info.text = "%s • HP %d" % [e["hero_class"], e["base_hp"]]
        info.add_theme_font_size_override("font_size", 10)
        info.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
        vbox.add_child(info)
        enemy_grid.add_child(panel)

func _on_start_battle():
    var stage = int(stage_input.value)
    var player_heroes = GameManager.get_player_heroes()
    if player_heroes.is_empty():
        return

    var enemies = BattleEngine.generate_enemy_team(stage)
    var result = BattleEngine.simulate_battle(player_heroes, enemies)

    # Apply rewards
    if result["winner"] == "player":
        GameManager.add_gold(result["rewards"]["gold"])
        GameManager.add_exp(result["rewards"]["exp"])
        if stage >= GameManager.progress["current_campaign_stage"]:
            GameManager.progress["current_campaign_stage"] = stage + 1
            GameManager.save_game()
        result_title.text = "🏆 VICTORY!"
        result_title.add_theme_color_override("font_color", Color(0.2, 0.8, 0.3))
    else:
        result_title.text = "💀 DEFEAT"
        result_title.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))

    result_details.text = "Rounds: %d\nDamage Dealt: %d\nDamage Taken: %d" % [result["rounds"], result["damage_dealt"], result["damage_taken"]]

    var rewards_text = "💰 %d Gold\n⭐ %d EXP" % [result["rewards"]["gold"], result["rewards"]["exp"]]
    for item in result["rewards"]["items"]:
        rewards_text += "\n📦 " + item
    rewards_label.text = rewards_text

    result_panel.visible = true
    update_info()
    refresh_enemy_preview()
