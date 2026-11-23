# scripts/ui/summon_ui.gd
extends Control

@onready var ticket_label = $VBox/TicketPanel/VBox/TicketLabel
@onready var summon1_btn = $VBox/TicketPanel/VBox/BtnRow/Summon1Btn
@onready var summon10_btn = $VBox/TicketPanel/VBox/BtnRow/Summon10Btn
@onready var result_panel = $VBox/ResultPanel
@onready var result_name = $VBox/ResultPanel/VBox/ResultName
@onready var result_info = $VBox/ResultPanel/VBox/ResultInfo
@onready var featured_grid = $VBox/Scroll/FeaturedGrid

const RARITY_COLORS = {
    "SSR": Color(0.8, 0.8, 0.8),
    "SSR+": Color(0.2, 0.5, 1.0),
    "UR": Color(0.6, 0.3, 0.9),
    "UR+": Color(0.95, 0.3, 0.7),
    "EX": Color(0.98, 0.75, 0.14),
}

func _ready():
    $VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    summon1_btn.pressed.connect(func(): _on_summon(1))
    summon10_btn.pressed.connect(func(): _on_summon(10))
    update_ticket_label()
    load_featured()

func update_ticket_label():
    ticket_label.text = "Ticket Tersedia: %d" % GameManager.progress["tickets"]

func _on_summon(count: int):
    if GameManager.progress["tickets"] < count:
        return
    
    var last_hero = null
    for i in range(count):
        if not GameManager.spend_tickets(1):
            break
        var templates = HeroesData.get_all_templates()
        var template = templates[randi() % templates.size()]
        var hero = HeroesData.create_hero_from_template(template)
        GameManager.add_hero(hero)
        last_hero = hero
    
    if last_hero != null:
        result_panel.visible = true
        result_name.text = last_hero["hero_name"]
        result_name.add_theme_color_override("font_color", RARITY_COLORS.get(last_hero["rarity"], Color.WHITE))
        result_info.text = "%s • %s • %s" % [last_hero["rarity"], last_hero["hero_class"], last_hero["anime_origin"]]
    
    update_ticket_label()

func load_featured():
    for child in featured_grid.get_children():
        child.queue_free()
    var templates = HeroesData.get_all_templates()
    for t in templates:
        if t["rarity"] in ["SSR+", "UR", "UR+", "EX"]:
            var panel = PanelContainer.new()
            panel.custom_minimum_size = Vector2(0, 60)
            var vbox = VBoxContainer.new()
            panel.add_child(vbox)
            var name_l = Label.new()
            name_l.text = t["hero_name"]
            name_l.add_theme_color_override("font_color", RARITY_COLORS.get(t["rarity"], Color.WHITE))
            name_l.add_theme_font_size_override("font_size", 12)
            name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            vbox.add_child(name_l)
            var info = Label.new()
            info.text = t["anime_origin"]
            info.add_theme_font_size_override("font_size", 10)
            info.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
            info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            vbox.add_child(info)
            featured_grid.add_child(panel)
            if featured_grid.get_child_count() >= 6:
                break
