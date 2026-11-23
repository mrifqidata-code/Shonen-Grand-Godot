# scripts/ui/heroes_ui.gd
extends Control

@onready var hero_grid = $VBox/Scroll/HeroGrid
@onready var count_label = $VBox/Header/CountLabel

const RARITY_COLORS = {
    "SSR": Color(0.8, 0.8, 0.8),
    "SSR+": Color(0.2, 0.5, 1.0),
    "UR": Color(0.6, 0.3, 0.9),
    "UR+": Color(0.95, 0.3, 0.7),
    "EX": Color(0.98, 0.75, 0.14),
}

func _ready():
    $VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    refresh_heroes()

func refresh_heroes():
    # Clear existing
    for child in hero_grid.get_children():
        child.queue_free()
    
    var heroes = GameManager.heroes
    count_label.text = "(%d)" % heroes.size()
    
    if heroes.is_empty():
        var empty_label = Label.new()
        empty_label.text = "Belum ada hero. Summon dulu!"
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        hero_grid.add_child(empty_label)
        return
    
    for hero in heroes:
        var card = create_hero_card(hero)
        hero_grid.add_child(card)

func create_hero_card(hero: Dictionary) -> PanelContainer:
    var panel = PanelContainer.new()
    panel.custom_minimum_size = Vector2(0, 120)
    
    var vbox = VBoxContainer.new()
    panel.add_child(vbox)
    
    # Name + rarity
    var name_label = Label.new()
    name_label.text = hero["hero_name"]
    name_label.add_theme_color_override("font_color", RARITY_COLORS.get(hero["rarity"], Color.WHITE))
    name_label.add_theme_font_size_override("font_size", 16)
    vbox.add_child(name_label)
    
    # Info
    var info = Label.new()
    var faction_name = Faction.get_name(hero["faction"])
    info.text = "%s • %s • %s" % [hero["anime_origin"], hero["hero_class"], faction_name]
    info.add_theme_font_size_override("font_size", 11)
    info.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
    vbox.add_child(info)
    
    # Stats
    var stats = Label.new()
    stats.text = "⭐%d • Lv.%d • LB%d" % [hero["star_level"], hero["level"], hero["limit_break"]]
    stats.add_theme_font_size_override("font_size", 12)
    vbox.add_child(stats)
    
    var stats2 = Label.new()
    stats2.text = "HP:%d ATK:%d DEF:%d" % [hero["base_hp"], hero["base_atk"], hero["base_def"]]
    stats2.add_theme_font_size_override("font_size", 11)
    vbox.add_child(stats2)
    
    # Buttons
    var hbox = HBoxContainer.new()
    vbox.add_child(hbox)
    
    var upgrade_btn = Button.new()
    upgrade_btn.text = "Upgrade (%dg)" % (hero["level"] * 50)
    upgrade_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    upgrade_btn.pressed.connect(func(): _on_upgrade(hero["id"]))
    hbox.add_child(upgrade_btn)
    
    var star_btn = Button.new()
    star_btn.text = "Star Up"
    star_btn.pressed.connect(func(): _on_star_up(hero["id"]))
    hbox.add_child(star_btn)
    
    return panel

func _on_upgrade(hero_id: String):
    if GameManager.upgrade_hero(hero_id):
        refresh_heroes()

func _on_star_up(hero_id: String):
    if GameManager.star_up_hero(hero_id):
        refresh_heroes()
