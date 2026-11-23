# scripts/ui/home_ui.gd
extends Control

@onready var level_value = $Scroll/VBox/StatsGrid/LevelBox/VBox/Value
@onready var gold_value = $Scroll/VBox/StatsGrid/GoldBox/VBox/Value
@onready var diamond_value = $Scroll/VBox/StatsGrid/DiamondBox/VBox/Value
@onready var ticket_value = $Scroll/VBox/StatsGrid/TicketBox/VBox/Value
@onready var idle_panel = $Scroll/VBox/IdlePanel
@onready var idle_time_label = $Scroll/VBox/IdlePanel/VBox/TimeLabel
@onready var idle_reward_label = $Scroll/VBox/IdlePanel/VBox/RewardLabel
@onready var claim_btn = $Scroll/VBox/IdlePanel/VBox/ClaimIdleBtn
@onready var campaign_progress = $Scroll/VBox/CampaignPanel/VBox/HBox/ProgressBar
@onready var stage_label = $Scroll/VBox/CampaignPanel/VBox/HBox/StageLabel

var idle_rewards: Dictionary = {}

func _ready():
    update_ui()
    claim_btn.pressed.connect(_on_claim_idle)
    $Scroll/VBox/QuickActions/BtnBattle.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/battle.tscn"))
    $Scroll/VBox/QuickActions/BtnSummon.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/summon.tscn"))
    $Scroll/VBox/QuickActions/BtnTeam.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/team.tscn"))
    $Scroll/VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    
    # Calculate idle rewards
    idle_rewards = GameManager.calculate_idle_rewards()
    if idle_rewards["time_elapsed"] > 60:
        idle_panel.visible = true
        update_idle_display()
    else:
        idle_panel.visible = false

func update_ui():
    level_value.text = str(GameManager.progress["level"])
    gold_value.text = str(GameManager.progress["gold"])
    diamond_value.text = str(GameManager.progress["diamonds"])
    ticket_value.text = str(GameManager.progress["tickets"])
    var stage = GameManager.progress["current_campaign_stage"]
    stage_label.text = "Stage %d" % stage
    campaign_progress.value = min(100.0, float(stage) / 50.0 * 100.0)

func update_idle_display():
    var time_str = format_time(idle_rewards["time_elapsed"])
    idle_time_label.text = "Waktu idle: " + time_str
    idle_reward_label.text = "💰 %d Gold • ⭐ %d EXP • 🎫 %d Ticket" % [idle_rewards["gold"], idle_rewards["exp"], idle_rewards["tickets"]]

func format_time(seconds: int) -> String:
    var h = seconds / 3600
    var m = (seconds % 3600) / 60
    var s = seconds % 60
    if h > 0:
        return "%dh %dm" % [h, m]
    if m > 0:
        return "%dm %ds" % [m, s]
    return "%ds" % s

func _on_claim_idle():
    var rewards = GameManager.collect_idle_rewards()
    idle_panel.visible = false
    update_ui()
