# scripts/domain/hero.gd
extends Resource
class_name Hero

@export var id: String = ""
@export var hero_name: String = ""
@export var hero_class: String = "Assault"  # Guard, Assault, Assassin, Control, Support
@export var faction: int = 0  # Faction.FactionType
@export var rarity: String = "SSR"
@export var anime_origin: String = ""

@export var base_hp: int = 1000
@export var base_atk: int = 300
@export var base_def: int = 150
@export var base_spd: int = 100
@export var base_crit_rate: float = 0.15
@export var base_crit_dmg: float = 1.5

@export var star_level: int = 1
@export var level: int = 1
@export var limit_break: int = 0
@export var awakened: bool = false
@export var copies: int = 0

@export var skills: Array = []  # Array of Dictionary
@export var bonds: Array = []  # Array of hero IDs

func get_max_hp() -> int:
    return int(base_hp * (1.0 + star_level * 0.2) * (1.0 + limit_break * 0.1))

func get_atk() -> int:
    return int(base_atk * (1.0 + star_level * 0.15) * (1.0 + limit_break * 0.1))

func get_def() -> int:
    return int(base_def * (1.0 + star_level * 0.1) * (1.0 + limit_break * 0.05))

func to_dict() -> Dictionary:
    return {
        "id": id,
        "hero_name": hero_name,
        "hero_class": hero_class,
        "faction": faction,
        "rarity": rarity,
        "anime_origin": anime_origin,
        "base_hp": base_hp,
        "base_atk": base_atk,
        "base_def": base_def,
        "base_spd": base_spd,
        "base_crit_rate": base_crit_rate,
        "base_crit_dmg": base_crit_dmg,
        "star_level": star_level,
        "level": level,
        "limit_break": limit_break,
        "awakened": awakened,
        "copies": copies,
        "skills": skills,
        "bonds": bonds,
    }

func from_dict(data: Dictionary):
    id = data.get("id", "")
    hero_name = data.get("hero_name", "")
    hero_class = data.get("hero_class", "Assault")
    faction = data.get("faction", 0)
    rarity = data.get("rarity", "SSR")
    anime_origin = data.get("anime_origin", "")
    base_hp = data.get("base_hp", 1000)
    base_atk = data.get("base_atk", 300)
    base_def = data.get("base_def", 150)
    base_spd = data.get("base_spd", 100)
    base_crit_rate = data.get("base_crit_rate", 0.15)
    base_crit_dmg = data.get("base_crit_dmg", 1.5)
    star_level = data.get("star_level", 1)
    level = data.get("level", 1)
    limit_break = data.get("limit_break", 0)
    awakened = data.get("awakened", false)
    copies = data.get("copies", 0)
    skills = data.get("skills", [])
    bonds = data.get("bonds", [])
