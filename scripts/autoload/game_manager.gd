# scripts/autoload/game_manager.gd
extends Node

# Player progress
var progress: Dictionary = {
    "level": 1,
    "exp": 0,
    "gold": 5000,
    "diamonds": 100,
    "tickets": 30,
    "friendship_points": 100,
    "advanced_scrolls": 3,
    "noble_insignia": 0,
    "hero_shards": 0,
    "idle_accumulated_at": 0,
    "current_campaign_stage": 1,
    "tower_floor": 1,
    "last_login": 0,
}

var heroes: Array = []
var teams: Array = []

# Player preferences (art style, toggles). Not reset by init_new_game().
var settings: Dictionary = {
    "character_style": "px64",
}

const SAVE_PATH = "user://save.json"
const MAX_IDLE_HOURS = 8

# Granted once to an empty account so the player can battle immediately.
const STARTER_HERO_IDS = ["naruto_uzumaki", "luffy_monkey", "ichigo_kurosaki"]

func _ready():
    load_game()
    _ensure_progress_keys()
    if progress["idle_accumulated_at"] == 0:
        progress["idle_accumulated_at"] = Time.get_unix_time_from_system()
        progress["last_login"] = Time.get_unix_time_from_system()

func _ensure_progress_keys():
    var defaults := {
        "friendship_points": 100,
        "advanced_scrolls": 3,
        "noble_insignia": 0,
        "hero_shards": 0,
    }
    var changed := false
    for key in defaults:
        if not progress.has(key):
            progress[key] = defaults[key]
            changed = true
    if changed:
        save_game()

func init_new_game():
    progress = {
        "level": 1,
        "exp": 0,
        "gold": 5000,
        "diamonds": 100,
        "tickets": 30,
        "friendship_points": 100,
        "advanced_scrolls": 3,
        "noble_insignia": 0,
        "hero_shards": 0,
        "idle_accumulated_at": Time.get_unix_time_from_system(),
        "current_campaign_stage": 1,
        "tower_floor": 1,
        "last_login": Time.get_unix_time_from_system(),
    }
    heroes = []
    teams = [_default_team()]
    save_game()

func save_game():
    var data = {
        "progress": progress,
        "heroes": heroes,
        "teams": teams,
        "settings": settings,
    }
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.close()

func load_game():
    if not FileAccess.file_exists(SAVE_PATH):
        init_new_game()
    else:
        var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
        if file:
            var json = JSON.new()
            var err = json.parse(file.get_as_text())
            file.close()
            if err == OK:
                var data = json.get_data()
                progress = data.get("progress", progress)
                heroes = data.get("heroes", [])
                teams = data.get("teams", [])
                settings = data.get("settings", settings)
    _ensure_starter_heroes()
    _ensure_team_slots()
    _ensure_hero_template_ids()
    # Older saves may hold heroes that were never placed on the team.
    _fill_empty_team_slots()

func _ensure_hero_template_ids():
    var changed := false
    for hero in heroes:
        if str(hero.get("template_id", "")).is_empty():
            hero["template_id"] = HeroesData.template_id_of(hero)
            changed = true
    if changed:
        save_game()

func _ensure_starter_heroes():
    if not heroes.is_empty():
        return
    var granted = false
    for template_id in STARTER_HERO_IDS:
        var template = HeroesData.get_template_by_id(template_id)
        if template.is_empty():
            continue
        heroes.append(HeroesData.create_hero_from_template(template))
        granted = true
    if granted:
        save_game()

func _ensure_team_slots():
    if teams.is_empty():
        teams = [_default_team()]
        save_game()
        return
    var slots = teams[0].get("slots", [])
    if slots.size() != 6:
        teams[0]["slots"] = _default_team()["slots"]
        save_game()

func _default_team() -> Dictionary:
    var slots = []
    for i in range(6):
        slots.append({"position": i + 1, "hero_id": null})
    return {"id": "team_1", "name": "Main Team", "slots": slots}

func _auto_assign_hero(hero_id: String) -> bool:
    if hero_id.is_empty() or teams.is_empty():
        return false
    for slot in teams[0].get("slots", []):
        if slot["hero_id"] == null:
            slot["hero_id"] = hero_id
            return true
    return false

func _fill_empty_team_slots():
    if heroes.is_empty() or teams.is_empty():
        return
    var assigned = []
    for slot in teams[0].get("slots", []):
        if slot["hero_id"] != null:
            assigned.append(slot["hero_id"])
    var changed = false
    for hero in heroes:
        var hero_id = str(hero.get("id", ""))
        if hero_id.is_empty() or assigned.has(hero_id):
            continue
        if _auto_assign_hero(hero_id):
            assigned.append(hero_id)
            changed = true
        else:
            break
    if changed:
        save_game()

func get_team_hero_count() -> int:
    return get_player_heroes().size()

func get_character_style() -> String:
    var style: String = str(settings.get("character_style", "px64"))
    if style.is_empty():
        style = "px64"
    return style

func set_character_style(style_id: String):
    settings["character_style"] = style_id
    save_game()

func get_hero_by_id(hero_id: String) -> Dictionary:
    for h in heroes:
        if h["id"] == hero_id:
            return h
    return {}

func add_hero(hero_data: Dictionary):
    heroes.append(hero_data)
    # New heroes join the battle team automatically while a slot is free.
    _auto_assign_hero(str(hero_data.get("id", "")))
    save_game()

func update_progress(key: String, value):
    progress[key] = value
    save_game()

func add_gold(amount: int):
    progress["gold"] += amount
    save_game()

func add_exp(amount: int):
    progress["exp"] += amount
    var exp_needed = progress["level"] * 100
    while progress["exp"] >= exp_needed:
        progress["level"] += 1
        progress["exp"] -= exp_needed
        exp_needed = progress["level"] * 100
    save_game()

func spend_gold(amount: int) -> bool:
    if progress["gold"] >= amount:
        progress["gold"] -= amount
        save_game()
        return true
    return false

func spend_tickets(amount: int) -> bool:
    if progress["tickets"] >= amount:
        progress["tickets"] -= amount
        save_game()
        return true
    return false

func spend_progress(key: String, amount: int) -> bool:
    if int(progress.get(key, 0)) >= amount:
        progress[key] = int(progress.get(key, 0)) - amount
        save_game()
        return true
    return false

func add_progress(key: String, amount: int):
    progress[key] = int(progress.get(key, 0)) + amount

func get_team() -> Dictionary:
    if teams.size() > 0:
        return teams[0]
    return {}

func upgrade_hero(hero_id: String) -> bool:
    var hero = get_hero_by_id(hero_id)
    if hero.is_empty():
        return false
    var cost = hero["level"] * 50
    if not spend_gold(cost):
        return false
    # Update hero level
    for i in range(heroes.size()):
        if heroes[i]["id"] == hero_id:
            heroes[i]["level"] += 1
            break
    save_game()
    return true

func star_up_hero(hero_id: String) -> bool:
    var hero = get_hero_by_id(hero_id)
    if hero.is_empty():
        return false
    if hero["copies"] < 1 or hero["star_level"] >= 5:
        return false
    for i in range(heroes.size()):
        if heroes[i]["id"] == hero_id:
            heroes[i]["star_level"] += 1
            heroes[i]["copies"] -= 1
            break
    save_game()
    return true

func get_player_heroes() -> Array:
    var team = get_team()
    var result = []
    for slot in team.get("slots", []):
        if slot["hero_id"] != null:
            var hero = get_hero_by_id(slot["hero_id"])
            if not hero.is_empty():
                result.append(hero)
    return result

func calculate_idle_rewards() -> Dictionary:
    var now = Time.get_unix_time_from_system()
    var last = progress.get("idle_accumulated_at", now)
    var elapsed_ms = min(now - last, MAX_IDLE_HOURS * 3600) * 1000
    var elapsed_sec = floor(elapsed_ms / 1000.0)
    
    var level_mult = 1.0 + (progress["level"] - 1) * 0.1
    
    return {
        "gold": floor(5 * elapsed_sec * level_mult),
        "exp": floor(2 * elapsed_sec * level_mult),
        "tickets": floor((elapsed_sec / 60.0) * 0.05),
        "time_elapsed": elapsed_sec,
    }

func collect_idle_rewards():
    var rewards = calculate_idle_rewards()
    progress["gold"] += rewards["gold"]
    progress["exp"] += rewards["exp"]
    progress["tickets"] += rewards["tickets"]
    progress["idle_accumulated_at"] = Time.get_unix_time_from_system()
    progress["last_login"] = Time.get_unix_time_from_system()
    
    # Level up check
    var exp_needed = progress["level"] * 100
    while progress["exp"] >= exp_needed:
        progress["level"] += 1
        progress["exp"] -= exp_needed
        exp_needed = progress["level"] * 100
    
    save_game()
    return rewards
