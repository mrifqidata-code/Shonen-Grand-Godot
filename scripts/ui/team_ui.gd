# scripts/ui/team_ui.gd
extends Control

@onready var slots_grid = $VBox/TeamPanel/VBox/SlotsGrid
@onready var hero_list = $VBox/Scroll/HeroList

func _ready():
    $VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    refresh_ui()

func refresh_ui():
    # Clear slots
    for child in slots_grid.get_children():
        child.queue_free()
    for child in hero_list.get_children():
        child.queue_free()
    
    var team = GameManager.get_team()
    var heroes = GameManager.heroes
    
    # Build slots
    for slot in team.get("slots", []):
        var slot_panel = PanelContainer.new()
        slot_panel.custom_minimum_size = Vector2(0, 80)
        slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        
        var vbox = VBoxContainer.new()
        slot_panel.add_child(vbox)
        
        var pos_label = Label.new()
        pos_label.text = "Slot %d" % slot["position"]
        pos_label.add_theme_font_size_override("font_size", 10)
        pos_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
        vbox.add_child(pos_label)
        
        if slot["hero_id"] != null:
            var hero = GameManager.get_hero_by_id(slot["hero_id"])
            if not hero.is_empty():
                var name_label = Label.new()
                name_label.text = hero["hero_name"]
                name_label.add_theme_font_size_override("font_size", 12)
                vbox.add_child(name_label)
                
                var info = Label.new()
                info.text = "Lv.%d ⭐%d" % [hero["level"], hero["star_level"]]
                info.add_theme_font_size_override("font_size", 10)
                vbox.add_child(info)
                
                var remove_btn = Button.new()
                remove_btn.text = "Remove"
                remove_btn.add_theme_font_size_override("font_size", 10)
                remove_btn.pressed.connect(func(): _on_remove(slot["position"]))
                vbox.add_child(remove_btn)
        else:
            var empty = Label.new()
            empty.text = "Empty"
            empty.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
            empty.add_theme_font_size_override("font_size", 11)
            vbox.add_child(empty)
        
        slots_grid.add_child(slot_panel)
    
    # Build hero list
    for hero in heroes:
        var in_team = false
        for slot in team.get("slots", []):
            if slot["hero_id"] == hero["id"]:
                in_team = true
                break
        
        if in_team:
            continue
        
        var card = PanelContainer.new()
        card.custom_minimum_size = Vector2(0, 50)
        
        var hbox = HBoxContainer.new()
        card.add_child(hbox)
        
        var info_vbox = VBoxContainer.new()
        info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        hbox.add_child(info_vbox)
        
        var name_label = Label.new()
        name_label.text = hero["hero_name"]
        name_label.add_theme_font_size_override("font_size", 13)
        info_vbox.add_child(name_label)
        
        var sub = Label.new()
        sub.text = "%s • %s" % [hero["hero_class"], Faction.display_name(hero["faction"])]
        sub.add_theme_font_size_override("font_size", 10)
        sub.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
        info_vbox.add_child(sub)
        
        var add_btn = Button.new()
        add_btn.text = "Add"
        add_btn.pressed.connect(func(): _on_add_hero(hero["id"]))
        hbox.add_child(add_btn)
        
        hero_list.add_child(card)

    if heroes.is_empty():
        var empty_box = VBoxContainer.new()
        empty_box.add_theme_constant_override("separation", 6)

        var empty_label = Label.new()
        empty_label.text = "Belum punya hero.\nSummon dulu, hero baru otomatis masuk slot tim kosong."
        empty_label.add_theme_font_size_override("font_size", 12)
        empty_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
        empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty_box.add_child(empty_label)

        var summon_btn = Button.new()
        summon_btn.text = "🎁 Summon Hero"
        summon_btn.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/summon.tscn"))
        empty_box.add_child(summon_btn)

        hero_list.add_child(empty_box)

func _on_add_hero(hero_id: String):
    var team = GameManager.get_team()
    # Find first empty slot
    for slot in team["slots"]:
        if slot["hero_id"] == null:
            # Update team
            for t in GameManager.teams:
                if t["id"] == team["id"]:
                    for s in t["slots"]:
                        if s["position"] == slot["position"]:
                            s["hero_id"] = hero_id
            GameManager.save_game()
            refresh_ui()
            return

func _on_remove(position: int):
    var team = GameManager.get_team()
    for t in GameManager.teams:
        if t["id"] == team["id"]:
            for s in t["slots"]:
                if s["position"] == position:
                    s["hero_id"] = null
    GameManager.save_game()
    refresh_ui()
