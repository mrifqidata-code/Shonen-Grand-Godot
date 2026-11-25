# scripts/domain/faction.gd
extends RefCounted
class_name Faction

enum FactionType { LIGHTFORGED, ARCANE, KINDRED, DEMONHUNT, VOID }

const FACTION_DATA = {
    FactionType.LIGHTFORGED: {
        "name": "Lightforged Sanctuary",
        "theme": "Cahaya & Malaikat",
        "color": Color(0.98, 0.75, 0.14),
        "strong_against": FactionType.ARCANE,
        "weak_against": FactionType.DEMONHUNT,
    },
    FactionType.ARCANE: {
        "name": "Arcane Web Phantom",
        "theme": "Mistik & Kegelapan",
        "color": Color(0.66, 0.33, 0.97),
        "strong_against": FactionType.KINDRED,
        "weak_against": FactionType.LIGHTFORGED,
    },
    FactionType.KINDRED: {
        "name": "Reclusive Kindred",
        "theme": "Vampir & Monster Malam",
        "color": Color(0.86, 0.15, 0.15),
        "strong_against": FactionType.DEMONHUNT,
        "weak_against": FactionType.ARCANE,
    },
    FactionType.DEMONHUNT: {
        "name": "Demonhunt Blade",
        "theme": "Pemburu Iblis",
        "color": Color(0.06, 0.73, 0.51),
        "strong_against": FactionType.LIGHTFORGED,
        "weak_against": FactionType.KINDRED,
    },
    FactionType.VOID: {
        "name": "Otherworld Void",
        "theme": "Cosmic & Void",
        "color": Color(0.39, 0.40, 0.95),
        "strong_against": FactionType.LIGHTFORGED,
        "weak_against": FactionType.VOID,
    },
}

static func get_advantage(attacker: int, defender: int) -> float:
    var data = FACTION_DATA[attacker]
    if data["strong_against"] == defender:
        return 1.3  # +30% damage
    if data["weak_against"] == defender:
        return 0.7  # -30% damage
    return 1.0

static func get_crit_bonus(attacker: int, defender: int) -> float:
    var data = FACTION_DATA[attacker]
    if data["strong_against"] == defender:
        return 0.1  # +10% crit
    if data["weak_against"] == defender:
        return -0.1  # -10% crit
    return 0.0

# Note: must not be called get_name() — that clashes with Object.get_name().
static func display_name(faction: int) -> String:
    if not FACTION_DATA.has(faction):
        return "Unknown"
    return FACTION_DATA[faction]["name"]

static func get_color(faction: int) -> Color:
    return FACTION_DATA[faction]["color"]
