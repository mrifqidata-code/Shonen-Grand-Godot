# scripts/domain/battle.gd
extends RefCounted
class_name BattleEngine

static func calculate_damage(attacker: Dictionary, defender: Dictionary, skill_mult: float = 1.0) -> Dictionary:
    var faction_adv = Faction.get_advantage(attacker["faction"], defender["faction"])
    var faction_crit = Faction.get_crit_bonus(attacker["faction"], defender["faction"])
    
    var crit_rate = min(1.0, attacker["base_crit_rate"] + faction_crit)
    var is_crit = randf() < crit_rate
    
    var damage = attacker["base_atk"] * skill_mult * faction_adv
    damage = damage * (100.0 / (100.0 + defender["base_def"]))
    
    if is_crit:
        damage *= attacker["base_crit_dmg"]
    
    # Variance 0.9-1.1
    damage *= 0.9 + randf() * 0.2
    
    return {"damage": max(1, int(damage)), "is_crit": is_crit}

static func simulate_battle(player_team: Array, enemy_team: Array) -> Dictionary:
    var player_hp = []
    var enemy_hp = []
    
    for h in player_team:
        player_hp.append(int(h["base_hp"] * (1.0 + h["star_level"] * 0.2) * (1.0 + h["limit_break"] * 0.1)))
    for h in enemy_team:
        enemy_hp.append(int(h["base_hp"] * (1.0 + h["star_level"] * 0.2)))
    
    var total_dealt = 0
    var total_taken = 0
    var round_num = 0
    var max_rounds = 30
    
    while round_num < max_rounds:
        round_num += 1
        
        # Player attacks
        for i in range(player_team.size()):
            if player_hp[i] <= 0:
                continue
            var target = find_target(enemy_hp)
            if target == -1:
                break
            var skill_mult = 4.0 if (round_num % 6 == 0) else (2.5 if (round_num % 3 == 0) else 1.0)
            var result = calculate_damage(player_team[i], enemy_team[target], skill_mult)
            enemy_hp[target] -= result["damage"]
            total_dealt += result["damage"]
        
        # Check win
        if enemy_hp.all(func(hp): return hp <= 0):
            return {
                "winner": "player",
                "rounds": round_num,
                "damage_dealt": total_dealt,
                "damage_taken": total_taken,
                "rewards": {"gold": 100 + round_num * 10, "exp": 50 + round_num * 5, "items": ["exp_potion", "hero_shard"]}
            }
        
        # Enemy attacks
        for i in range(enemy_team.size()):
            if enemy_hp[i] <= 0:
                continue
            var target = find_target(player_hp)
            if target == -1:
                break
            var skill_mult = 3.5 if (round_num % 6 == 0) else (2.0 if (round_num % 3 == 0) else 1.0)
            var result = calculate_damage(enemy_team[i], player_team[target], skill_mult)
            player_hp[target] -= result["damage"]
            total_taken += result["damage"]
        
        # Check lose
        if player_hp.all(func(hp): return hp <= 0):
            return {
                "winner": "enemy",
                "rounds": round_num,
                "damage_dealt": total_dealt,
                "damage_taken": total_taken,
                "rewards": {"gold": 20 + round_num * 5, "exp": 10 + round_num * 2, "items": []}
            }
    
    # Timeout
    return {
        "winner": "enemy",
        "rounds": max_rounds,
        "damage_dealt": total_dealt,
        "damage_taken": total_taken,
        "rewards": {"gold": 20 + max_rounds * 5, "exp": 10 + max_rounds * 2, "items": []}
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
