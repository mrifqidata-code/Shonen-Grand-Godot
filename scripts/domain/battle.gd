# scripts/domain/battle.gd
extends RefCounted
class_name BattleEngine

# Ultimate energy: every basic action charges the gauge; at 100 the next action
# becomes the hero's ultimate skill (cinematic cut-in in the battle UI).
const ENERGY_MAX := 100
const PLAYER_ENERGY_PER_ACTION := 25  # ultimate every 5th action
const ENEMY_ENERGY_PER_ACTION := 20   # ultimate every 6th action
const ENEMY_ULT_MULT := 3.5
const ENEMY_ULT_NAME := "Dark Burst"


## The ultimate skill of a hero: {name, mult, desc}. Falls back to a generic one
## for enemies and any hero template without an ultimate entry.
static func ultimate_of(hero: Dictionary) -> Dictionary:
    for skill in hero.get("skills", []):
        if str(skill.get("type", "")) == "ultimate":
            return {
                "name": str(skill.get("name", "Ultimate")),
                "desc": str(skill.get("desc", "")),
                "mult": float(skill.get("mult", 4.0)),
            }
    return {"name": ENEMY_ULT_NAME, "desc": "", "mult": ENEMY_ULT_MULT}


static func hero_stat_mult(hero: Dictionary) -> float:
    # Grade + Awaken flat stat tiers (see GameConfig).
    return GameConfig.grade_mult(int(hero.get("grade", 0))) * GameConfig.awaken_mult(int(hero.get("awaken", 0)))


static func calculate_damage(attacker: Dictionary, defender: Dictionary, skill_mult: float = 1.0) -> Dictionary:
    var faction_adv = Faction.get_advantage(attacker["faction"], defender["faction"])
    var faction_crit = Faction.get_crit_bonus(attacker["faction"], defender["faction"])
    
    var crit_rate = min(1.0, attacker["base_crit_rate"] + faction_crit)
    var is_crit = randf() < crit_rate
    
    var damage = attacker["base_atk"] * skill_mult * faction_adv * hero_stat_mult(attacker)
    damage = damage * (100.0 / (100.0 + defender["base_def"]))
    
    if is_crit:
        damage *= attacker["base_crit_dmg"]
    
    # Variance 0.9-1.1
    damage *= 0.9 + randf() * 0.2
    
    return {"damage": max(1, int(damage)), "is_crit": is_crit}

static func player_max_hp(hero: Dictionary) -> int:
    return int(
        float(hero["base_hp"]) * (1.0 + float(hero["star_level"]) * 0.2) * (1.0 + float(hero["limit_break"]) * 0.1) * hero_stat_mult(hero)
    )


static func enemy_max_hp(hero: Dictionary) -> int:
    return int(float(hero["base_hp"]) * (1.0 + float(hero["star_level"]) * 0.2))


static func simulate_battle(player_team: Array, enemy_team: Array) -> Dictionary:
    var player_hp := []
    var enemy_hp := []
    var player_max := []
    var enemy_max := []
    var player_energy := []
    var enemy_energy := []

    for h in player_team:
        var hp := player_max_hp(h)
        player_hp.append(hp)
        player_max.append(hp)
        player_energy.append(0)
    for h in enemy_team:
        var hp := enemy_max_hp(h)
        enemy_hp.append(hp)
        enemy_max.append(hp)
        enemy_energy.append(0)

    # Per-hit event log used by the battle playback UI (animations + damage numbers).
    var events := []
    var total_dealt := 0
    var total_taken := 0
    var ultimates := 0
    var round_num := 0
    var max_rounds := 30

    while round_num < max_rounds:
        round_num += 1

        # Player attacks
        for i in range(player_team.size()):
            if player_hp[i] <= 0:
                continue
            var target := find_target(enemy_hp)
            if target == -1:
                break
            var ult := ultimate_of(player_team[i])
            var use_ult: bool = player_energy[i] >= ENERGY_MAX
            var mult: float = float(ult["mult"]) if use_ult else 1.0
            var energy_before := int(player_energy[i])
            player_energy[i] = 0 if use_ult else mini(ENERGY_MAX, player_energy[i] + PLAYER_ENERGY_PER_ACTION)
            if use_ult:
                ultimates += 1
            var result := calculate_damage(player_team[i], enemy_team[target], mult)
            enemy_hp[target] -= result["damage"]
            total_dealt += result["damage"]
            events.append({
                "round": round_num,
                "side": "player",
                "actor": i,
                "target": target,
                "damage": int(result["damage"]),
                "crit": bool(result["is_crit"]),
                "mult": mult,
                "ultimate": use_ult,
                "skill": str(ult["name"]) if use_ult else "",
                "energy_before": energy_before,
                "energy_after": int(player_energy[i]),
                "killed": enemy_hp[target] <= 0,
            })

        # Check win
        if enemy_hp.all(func(hp): return hp <= 0):
            return _battle_result(
                "player", round_num, total_dealt, total_taken, events, player_hp, enemy_hp, player_max, enemy_max, ultimates
            )

        # Enemy attacks
        for i in range(enemy_team.size()):
            if enemy_hp[i] <= 0:
                continue
            var target := find_target(player_hp)
            if target == -1:
                break
            var use_ult: bool = enemy_energy[i] >= ENERGY_MAX
            var mult: float = ENEMY_ULT_MULT if use_ult else 1.0
            var energy_before := int(enemy_energy[i])
            enemy_energy[i] = 0 if use_ult else mini(ENERGY_MAX, enemy_energy[i] + ENEMY_ENERGY_PER_ACTION)
            if use_ult:
                ultimates += 1
            var result := calculate_damage(enemy_team[i], player_team[target], mult)
            player_hp[target] -= result["damage"]
            total_taken += result["damage"]
            events.append({
                "round": round_num,
                "side": "enemy",
                "actor": i,
                "target": target,
                "damage": int(result["damage"]),
                "crit": bool(result["is_crit"]),
                "mult": mult,
                "ultimate": use_ult,
                "skill": ENEMY_ULT_NAME if use_ult else "",
                "energy_before": energy_before,
                "energy_after": int(enemy_energy[i]),
                "killed": player_hp[target] <= 0,
            })

        # Check lose
        if player_hp.all(func(hp): return hp <= 0):
            return _battle_result(
                "enemy", round_num, total_dealt, total_taken, events, player_hp, enemy_hp, player_max, enemy_max, ultimates
            )

    # Timeout
    return _battle_result(
        "enemy", max_rounds, total_dealt, total_taken, events, player_hp, enemy_hp, player_max, enemy_max, ultimates
    )


static func _battle_result(
    winner: String,
    rounds: int,
    dealt: int,
    taken: int,
    events: Array,
    player_hp: Array,
    enemy_hp: Array,
    player_max: Array,
    enemy_max: Array,
    ultimates: int = 0
) -> Dictionary:
    var rewards: Dictionary
    if winner == "player":
        rewards = {
            "gold": 100 + rounds * 10,
            "exp": 50 + rounds * 5,
            "items": ["exp_potion", "hero_shard"],
            "materials": {"courage_essence": 3 + int(rounds / 5)},
        }
    else:
        rewards = {"gold": 20 + rounds * 5, "exp": 10 + rounds * 2, "items": [], "materials": {}}
    return {
        "winner": winner,
        "rounds": rounds,
        "damage_dealt": dealt,
        "damage_taken": taken,
        "ultimates": ultimates,
        "rewards": rewards,
        "events": events,
        "player_hp": player_hp,
        "enemy_hp": enemy_hp,
        "player_max_hp": player_max,
        "enemy_max_hp": enemy_max,
    }

static func find_target(hp_array: Array) -> int:
    var min_hp = INF
    var idx = -1
    for i in range(hp_array.size()):
        if hp_array[i] > 0 and hp_array[i] < min_hp:
            min_hp = hp_array[i]
            idx = i
    return idx

static func generate_enemy_team(stage: int) -> Array:
    var templates = [
        {"name": "Shadow Minion", "hero_class": "Assault", "faction": 4, "hp": 800, "atk": 200, "def": 100, "spd": 100, "crit_rate": 0.1, "crit_dmg": 1.4},
        {"name": "Cultist", "hero_class": "Control", "faction": 1, "hp": 700, "atk": 220, "def": 90, "spd": 110, "crit_rate": 0.12, "crit_dmg": 1.5},
        {"name": "Dark Knight", "hero_class": "Guard", "faction": 3, "hp": 1500, "atk": 180, "def": 250, "spd": 80, "crit_rate": 0.08, "crit_dmg": 1.3},
    ]
    
    var scale = 1.0 + (stage - 1) * 0.15
    var team_size = min(6, 2 + int(stage / 5))
    var team = []
    
    for i in range(team_size):
        var t = templates[i % templates.size()]
        team.append({
            "id": "enemy_%d_%d" % [stage, i],
            "hero_name": "%s Lv.%d" % [t["name"], stage],
            "hero_class": t["hero_class"],
            "faction": t["faction"],
            "rarity": "SSR",
            "anime_origin": "Enemy",
            "base_hp": int(t["hp"] * scale),
            "base_atk": int(t["atk"] * scale),
            "base_def": int(t["def"] * scale),
            "base_spd": t["spd"],
            "base_crit_rate": t["crit_rate"],
            "base_crit_dmg": t["crit_dmg"],
            "star_level": int(stage / 10) + 1,
            "level": stage,
            "limit_break": 0,
            "awakened": false,
            "copies": 0,
            "skills": [],
            "bonds": [],
        })
    
    return team
