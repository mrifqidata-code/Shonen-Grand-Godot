# scripts/ui/battle_ui.gd
extends Control

@onready var stage_input = $VBox/StageRow/StageInput
@onready var start_btn = $VBox/StageRow/StartBtn
@onready var info_label = $VBox/InfoLabel
@onready var result_panel = $VBox/ResultPanel
@onready var result_title = $VBox/ResultPanel/VBox/ResultTitle
@onready var result_details = $VBox/ResultPanel/VBox/ResultDetails
@onready var rewards_label = $VBox/ResultPanel/VBox/RewardsLabel
@onready var ok_btn = $VBox/ResultPanel/VBox/OkBtn
@onready var enemy_grid = $VBox/EnemyScroll/EnemyGrid

func _ready():
    $VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    start_btn.pressed.connect(_on_start_battle)
    ok_btn.pressed.connect(func(): result_panel.visible = false)
    stage_input.value = GameManager.progress["current_campaign_stage"]
    update_info()
    refresh_enemy_preview()

func update_info():
    var heroes = GameManager.get_player_heroes()
    info_label.text = "Tim: %d hero • Stage saat ini: %d" % [heroes.size(), GameManager.progress["current_campaign_stage"]]

func refresh_enemy_preview():
    for child in enemy_grid.get_children():
        child.queue_free()
    var stage = int(stage_input.value)
    var enemies = BattleEngine.generate_enemy_team(stage)
    for e in enemies:
        var panel = PanelContainer.new()
        panel.custom_minimum_size = Vector2(0, 60)
        var vbox = VBoxContainer.new()
        panel.add_child(vbox)
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
