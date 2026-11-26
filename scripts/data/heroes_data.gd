# scripts/data/heroes_data.gd
# Hero roster generated from the tier builder (64 heroes, 7 tiers).
# Roster rows: [id, name, class, faction, rarity, origin]
# faction: 0 LIGHTFORGED, 1 ARCANE, 2 KINDRED, 3 DEMONHUNT, 4 VOID
extends RefCounted
class_name HeroesData

const ROSTER := [
	# === EX (8) ===
	["sukuna", "Sukuna", "Assault", 4, "EX", "Jujutsu Kaisen"],
	["hashirama", "Hashirama", "Support", 4, "EX", "Naruto"],
	["naruto_six_path", "Naruto Six Path", "Assault", 4, "EX", "Naruto"],
	["yhwach", "Yhwach", "Control", 4, "EX", "Bleach"],
	["ichigo_final", "Final Form Ichigo", "Assassin", 4, "EX", "Bleach"],
	["blast", "Blast", "Support", 4, "EX", "One Punch Man"],
	["kaido", "Kaido", "Guard", 4, "EX", "One Piece"],
	["goku", "Goku", "Assault", 4, "EX", "Dragon Ball"],
	# === UR (8) ===
	["kaguya", "Kaguya", "Support", 4, "UR", "Naruto"],
	["sasuke_indra", "Sasuke Indra", "Assassin", 4, "UR", "Naruto"],
	["aizen_final", "Aizen Final Form", "Control", 4, "UR", "Bleach"],
	["gojo", "Gojo", "Assault", 4, "UR", "Jujutsu Kaisen"],
	["luffy_gear5", "Luffy 5th Gear", "Guard", 4, "UR", "One Piece"],
	["garou_cosmic", "Garou Cosmic", "Assassin", 4, "UR", "One Punch Man"],
	["saitama_serious", "Saitama Serious", "Assassin", 4, "UR", "One Punch Man"],
	["urahara", "Urahara", "Support", 4, "UR", "Bleach"],
	# === SSR+ core (16) ===
	["itachi", "Itachi", "Control", 1, "SSR+", "Naruto"],
	["tsunade", "Tsunade", "Support", 0, "SSR+", "Naruto"],
	["minato", "Minato", "Assassin", 0, "SSR+", "Naruto"],
	["obito", "Obito", "Control", 3, "SSR+", "Naruto"],
	["madara", "Madara", "Guard", 1, "SSR+", "Naruto"],
	["byakuya", "Byakuya", "Control", 0, "SSR+", "Bleach"],
	["ulquiorra", "Ulquiorra", "Assassin", 3, "SSR+", "Bleach"],
	["ichigo", "Ichigo", "Assassin", 0, "SSR+", "Bleach"],
	["zoro", "Zoro", "Assault", 2, "SSR+", "One Piece"],
	["law", "Law", "Support", 1, "SSR+", "One Piece"],
	["blackbeard", "Blackbeard", "Guard", 3, "SSR+", "One Piece"],
	["mihawk", "Mihawk", "Assassin", 2, "SSR+", "One Piece"],
	["genos", "Genos", "Assault", 1, "SSR+", "One Punch Man"],
	["yamamoto", "Yamamoto", "Control", 2, "SSR+", "Bleach"],
	["yuta", "Yuta", "Assault", 3, "SSR+", "Jujutsu Kaisen"],
	["levi", "Levi", "Assassin", 2, "SSR+", "Attack on Titan"],
	# === SSR+ (8) ===
	["jiraiya", "Jiraiya", "Support", 1, "SSR+", "Naruto"],
	["gaara", "Gaara", "Guard", 1, "SSR+", "Naruto"],
	["pain", "Pain", "Assault", 1, "SSR+", "Naruto"],
	["starrk", "Starrk", "Assault", 3, "SSR+", "Bleach"],
	["grimmjow", "Grimmjow", "Assassin", 3, "SSR+", "Bleach"],
	["sanji", "Sanji", "Assault", 2, "SSR+", "One Piece"],
	["big_mom", "Big Mom", "Guard", 2, "SSR+", "One Piece"],
	["bang", "Bang", "Guard", 0, "SSR+", "One Punch Man"],
	# === SSR (8) ===
	["naruto_shippuden", "Naruto Shippuden", "Assault", 1, "SSR", "Naruto"],
	["kakashi", "Kakashi", "Assassin", 1, "SSR", "Naruto"],
	["might_guy", "Might Guy", "Guard", 2, "SSR", "Naruto"],
	["toshiro", "Toshiro", "Control", 3, "SSR", "Bleach"],
	["renji", "Renji", "Assault", 3, "SSR", "Bleach"],
	["unohana", "Unohana", "Support", 0, "SSR", "Bleach"],
	["ace", "Ace", "Assault", 2, "SSR", "One Piece"],
	["megumi", "Megumi", "Control", 3, "SSR", "Jujutsu Kaisen"],
	# === SR (8) ===
	["neji", "Neji", "Guard", 1, "SR", "Naruto"],
	["rock_lee", "Rock Lee", "Assault", 2, "SR", "Naruto"],
	["shikamaru", "Shikamaru", "Control", 1, "SR", "Naruto"],
	["rukia", "Rukia", "Control", 3, "SR", "Bleach"],
	["chad", "Chad", "Guard", 2, "SR", "Bleach"],
	["usopp", "Usopp", "Support", 2, "SR", "One Piece"],
	["franky", "Franky", "Guard", 2, "SR", "One Piece"],
	["yuji", "Yuji", "Assault", 3, "SR", "Jujutsu Kaisen"],
	# === R (8) ===
	["sakura", "Sakura", "Support", 1, "R", "Naruto"],
	["hinata", "Hinata", "Support", 0, "R", "Naruto"],
	["uryu", "Uryu", "Assassin", 0, "R", "Bleach"],
	["chopper", "Chopper", "Support", 2, "R", "One Piece"],
	["king", "King", "Guard", 2, "R", "One Piece"],
	["fubuki", "Fubuki", "Control", 1, "R", "One Punch Man"],
	["nobara", "Nobara", "Assassin", 3, "R", "Jujutsu Kaisen"],
	["tanjiro", "Tanjiro", "Assault", 3, "R", "Demon Slayer"],
]

# Base stats per rarity (before the class modifier is applied).
const RARITY_STATS := {
	"N": {"hp": 520, "atk": 115, "def": 80},
	"R": {"hp": 720, "atk": 160, "def": 105},
	"SR": {"hp": 940, "atk": 210, "def": 135},
	"SSR": {"hp": 1180, "atk": 265, "def": 165},
	"SSR+": {"hp": 1420, "atk": 320, "def": 200},
	"UR": {"hp": 1680, "atk": 385, "def": 240},
	"EX": {"hp": 1950, "atk": 455, "def": 285},
}

# Class role modifiers: hp/atk/def/spd multipliers plus crit base.
const CLASS_STATS := {
	"Assault": {"hp": 1.00, "atk": 1.15, "def": 0.95, "spd": 1.00, "crit": 0.15, "critdmg": 1.5},
	"Assassin": {"hp": 0.85, "atk": 1.25, "def": 0.85, "spd": 1.15, "crit": 0.28, "critdmg": 1.8},
	"Guard": {"hp": 1.30, "atk": 0.85, "def": 1.30, "spd": 0.90, "crit": 0.08, "critdmg": 1.4},
	"Support": {"hp": 1.10, "atk": 0.95, "def": 1.05, "spd": 1.00, "crit": 0.10, "critdmg": 1.4},
	"Control": {"hp": 1.05, "atk": 1.05, "def": 1.00, "spd": 1.05, "crit": 0.15, "critdmg": 1.5},
}

# One active + one ultimate + one passive per class, shared across heroes so the
# roster stays consistent. Names get the hero prefix so cut-ins stay distinct.
const CLASS_SKILLS := {
	"Assault": [
		{"id": "strike", "name": "Power Strike", "type": "active", "desc": "Serangan fisik kuat", "cooldown": 3, "mult": 2.6},
		{"id": "ult", "name": "Overdrive", "type": "ultimate", "desc": "Ledakan tenaga penuh", "cooldown": 6, "mult": 4.6},
		{"id": "passive", "name": "Battle Spirit", "type": "passive", "desc": "+10% ATK", "cooldown": 0, "mult": 1.0},
	],
	"Assassin": [
		{"id": "strike", "name": "Shadow Cut", "type": "active", "desc": "Tebasan cepat crit tinggi", "cooldown": 3, "mult": 3.0},
		{"id": "ult", "name": "Execution", "type": "ultimate", "desc": "Eksekusi mematikan", "cooldown": 6, "mult": 5.0},
		{"id": "passive", "name": "Killer Instinct", "type": "passive", "desc": "+10% crit rate", "cooldown": 0, "mult": 1.0},
	],
	"Guard": [
		{"id": "strike", "name": "Shield Bash", "type": "active", "desc": "Hantaman tameng", "cooldown": 3, "mult": 2.0},
		{"id": "ult", "name": "Fortress", "type": "ultimate", "desc": "Tembok pertahanan", "cooldown": 6, "mult": 3.4},
		{"id": "passive", "name": "Iron Wall", "type": "passive", "desc": "+15% DEF", "cooldown": 0, "mult": 1.0},
	],
	"Support": [
		{"id": "strike", "name": "Rally", "type": "active", "desc": "Serangan pendukung", "cooldown": 3, "mult": 2.1},
		{"id": "ult", "name": "Blessing", "type": "ultimate", "desc": "Berkah tim", "cooldown": 6, "mult": 3.2},
		{"id": "passive", "name": "Guidance", "type": "passive", "desc": "+10% HP tim", "cooldown": 0, "mult": 1.0},
	],
	"Control": [
		{"id": "strike", "name": "Bind", "type": "active", "desc": "Kunci gerak musuh", "cooldown": 3, "mult": 2.3},
		{"id": "ult", "name": "Dominion", "type": "ultimate", "desc": "Kendali total medan", "cooldown": 6, "mult": 4.0},
		{"id": "passive", "name": "Tactician", "type": "passive", "desc": "+10% SPD", "cooldown": 0, "mult": 1.0},
	],
}


static func _bonds_for(id: String) -> Array:
	var out := []
	for p in GameConfig.bond_partners(id):
		out.append(str(p["id"]))
	return out


static func _build(row: Array) -> Dictionary:
	var cls := str(row[2])
	var rarity := str(row[4])
	var base: Dictionary = RARITY_STATS.get(rarity, RARITY_STATS["SR"])
	var mod: Dictionary = CLASS_STATS.get(cls, CLASS_STATS["Control"])
	var skills := []
	for s in CLASS_SKILLS.get(cls, []):
		var sk: Dictionary = (s as Dictionary).duplicate(true)
		if str(sk["type"]) == "active" or str(sk["type"]) == "ultimate":
			sk["name"] = "%s: %s" % [str(row[1]), str(sk["name"])]
		skills.append(sk)
	return {
		"id": str(row[0]),
		"hero_name": str(row[1]),
		"hero_class": cls,
		"faction": int(row[3]),
		"rarity": rarity,
		"anime_origin": str(row[5]),
		"base_hp": int(round(float(base["hp"]) * float(mod["hp"]))),
		"base_atk": int(round(float(base["atk"]) * float(mod["atk"]))),
		"base_def": int(round(float(base["def"]) * float(mod["def"]))),
		"base_spd": int(round(100.0 * float(mod["spd"]))),
		"base_crit_rate": float(mod["crit"]),
		"base_crit_dmg": float(mod["critdmg"]),
		"skills": skills,
		"bonds": _bonds_for(str(row[0])),
	}


static func get_all_templates() -> Array:
	var out := []
	for row in ROSTER:
		out.append(_build(row))
	return out


static func get_template_by_id(template_id: String) -> Dictionary:
	for row in ROSTER:
		if str(row[0]) == template_id:
			return _build(row)
	return {}


## Template id for an owned hero. New saves store "template_id"; older saves
## only have the instance id ("<template_id>_<ms>_<rand>"), so strip that.
static func template_id_of(hero: Dictionary) -> String:
	var stored := str(hero.get("template_id", ""))
	if not stored.is_empty():
		return stored
	var raw := str(hero.get("id", ""))
	var parts := raw.split("_")
	if (
		parts.size() >= 3
		and parts[parts.size() - 1].is_valid_int()
		and parts[parts.size() - 2].is_valid_int()
	):
		return "_".join(parts.slice(0, parts.size() - 2))
	return raw


static func create_hero_from_template(template: Dictionary) -> Dictionary:
	# Unique per instance: 10x summon in the same frame must not share an id.
	var stamp = int(Time.get_unix_time_from_system() * 1000.0)
	return {
		"id": "%s_%d_%d" % [template["id"], stamp, randi() % 100000],
		"template_id": template["id"],
		"hero_name": template["hero_name"],
		"hero_class": template["hero_class"],
		"faction": template["faction"],
		"rarity": template["rarity"],
		"anime_origin": template["anime_origin"],
		"base_hp": template["base_hp"],
		"base_atk": template["base_atk"],
		"base_def": template["base_def"],
		"base_spd": template["base_spd"],
		"base_crit_rate": template["base_crit_rate"],
		"base_crit_dmg": template["base_crit_dmg"],
		"star_level": 1,
		"level": 1,
		"limit_break": 0,
		"grade": 0,
		"awaken": 0,
		"awakened": false,
		"copies": 0,
		"skills": template["skills"].duplicate(true),
		"bonds": template["bonds"].duplicate(),
	}
