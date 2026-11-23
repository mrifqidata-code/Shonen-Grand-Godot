# scripts/ui/inventory_ui.gd
extends Control

@onready var item_grid = $VBox/ItemGrid

func _ready():
    $VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    refresh_items()

func refresh_items():
    for child in item_grid.get_children():
        child.queue_free()
    
    var items = [
        {"id": "exp_potion", "name": "EXP Potion", "count": 12, "icon": "🧪", "desc": "Level up hero"},
        {"id": "hero_shard", "name": "Hero Shard", "count": 5, "icon": "💎", "desc": "Summon hero spesifik"},
        {"id": "star_shard", "name": "Star Shard", "count": 3, "icon": "⭐", "desc": "Star up hero"},
        {"id": "gold", "name": "Gold", "count": GameManager.progress["gold"], "icon": "💰", "desc": "Currency utama"},
    ]
    
    for item in items:
        var panel = PanelContainer.new()
        panel.custom_minimum_size = Vector2(0, 100)
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        
        var vbox = VBoxContainer.new()
        panel.add_child(vbox)
        
        var icon = Label.new()
        icon.text = item["icon"]
        icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        icon.add_theme_font_size_override("font_size", 32)
        vbox.add_child(icon)
        
        var name_l = Label.new()
        name_l.text = item["name"]
        name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_l.add_theme_font_size_override("font_size", 13)
        vbox.add_child(name_l)
        
        var desc = Label.new()
        desc.text = item["desc"]
        desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        desc.add_theme_font_size_override("font_size", 10)
        desc.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
        vbox.add_child(desc)
        
        var count = Label.new()
        count.text = str(item["count"])
        count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        count.add_theme_font_size_override("font_size", 18)
        count.add_theme_color_override("font_color", Color(0.98, 0.75, 0.14))
        vbox.add_child(count)
        
        item_grid.add_child(panel)
