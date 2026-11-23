# scripts/ui/main_ui.gd
extends Control

func _ready():
    $VBox/MenuButtons/BtnHome.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/home.tscn"))
    $VBox/MenuButtons/BtnHeroes.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/heroes.tscn"))
    $VBox/MenuButtons/BtnTeam.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/team.tscn"))
    $VBox/MenuButtons/BtnBattle.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/battle.tscn"))
    $VBox/MenuButtons/BtnSummon.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/summon.tscn"))
    $VBox/MenuButtons/BtnInventory.pressed.connect(func(): SceneManager.change_scene("res://scenes/ui/inventory.tscn"))
