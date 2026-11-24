# scripts/data/heroes_data.gd
extends RefCounted
class_name HeroesData

# Hero template: Dictionary with all base data
static func get_all_templates() -> Array:
    return [
        # === LIGHTFORGED (Naruto) ===
        {
            "id": "naruto_uzumaki",
            "hero_name": "Naruto Uzumaki",
            "hero_class": "Assault",
            "faction": 0,  # LIGHTFORGED
            "rarity": "SSR+",
            "anime_origin": "Naruto",
            "base_hp": 1200, "base_atk": 320, "base_def": 180,
            "base_spd": 110, "base_crit_rate": 0.15, "base_crit_dmg": 1.5,
            "skills": [
                {"id": "rasengan", "name": "Rasengan", "type": "active", "desc": "Bola chakra damage besar", "cooldown": 3, "mult": 2.5},
                {"id": "sage_mode", "name": "Sage Mode", "type": "ultimate", "desc": "Boost semua stat 50%", "cooldown": 6, "mult": 4.0},
                {"id": "shadow_clone", "name": "Shadow Clone", "type": "passive", "desc": "Serangan tambahan tiap 2 turn", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["sasuke_uchiha", "sakura_haruno"],
        },
        {
            "id": "sasuke_uchiha",
            "hero_name": "Sasuke Uchiha",
            "hero_class": "Assassin",
            "faction": 0,
            "rarity": "SSR+",
            "anime_origin": "Naruto",
            "base_hp": 900, "base_atk": 380, "base_def": 140,
            "base_spd": 130, "base_crit_rate": 0.25, "base_crit_dmg": 1.8,
            "skills": [
                {"id": "chidori", "name": "Chidori", "type": "active", "desc": "Serangan petir menembus defense", "cooldown": 3, "mult": 3.0},
                {"id": "amaterasu", "name": "Amaterasu", "type": "ultimate", "desc": "Api hitam membakar musuh", "cooldown": 6, "mult": 4.5},
                {"id": "sharingan", "name": "Sharingan", "type": "passive", "desc": "+20% crit rate, counter", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["naruto_uzumaki", "itachi_uchiha"],
        },
        {
            "id": "kakashi_hatake",
            "hero_name": "Kakashi Hatake",
            "hero_class": "Control",
            "faction": 0,
            "rarity": "SSR",
            "anime_origin": "Naruto",
            "base_hp": 1000, "base_atk": 260, "base_def": 160,
            "base_spd": 120, "base_crit_rate": 0.18, "base_crit_dmg": 1.5,
            "skills": [
                {"id": "raikiri", "name": "Raikiri", "type": "active", "desc": "Chidori sempurna", "cooldown": 3, "mult": 2.8},
                {"id": "kamui", "name": "Kamui", "type": "ultimate", "desc": "Teleportasi musuh ke dimensi lain", "cooldown": 7, "mult": 3.5},
                {"id": "copy_ninja", "name": "Copy Ninja", "type": "passive", "desc": "Copy skill musuh 1x", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["naruto_uzumaki", "sasuke_uchiha"],
        },
        # === ARCANE (JJK) ===
        {
            "id": "gojo_satoru",
            "hero_name": "Gojo Satoru",
            "hero_class": "Control",
            "faction": 1,  # ARCANE
            "rarity": "SSR+",
            "anime_origin": "Jujutsu Kaisen",
            "base_hp": 1100, "base_atk": 300, "base_def": 170,
            "base_spd": 125, "base_crit_rate": 0.20, "base_crit_dmg": 1.6,
            "skills": [
                {"id": "hollow_purple", "name": "Hollow Purple", "type": "active", "desc": "Gabungan Red+Blue, damage masif", "cooldown": 4, "mult": 3.2},
                {"id": "unlimited_void", "name": "Unlimited Void", "type": "ultimate", "desc": "Domain expansion, stun semua", "cooldown": 7, "mult": 2.0},
                {"id": "infinity", "name": "Infinity", "type": "passive", "desc": "30% chance menghindari serangan", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["yuji_itadori", "megumi_fushiguro"],
        },
        {
            "id": "yuji_itadori",
            "hero_name": "Yuji Itadori",
            "hero_class": "Assault",
            "faction": 1,
            "rarity": "SSR",
            "anime_origin": "Jujutsu Kaisen",
            "base_hp": 1300, "base_atk": 290, "base_def": 190,
            "base_spd": 105, "base_crit_rate": 0.15, "base_crit_dmg": 1.5,
            "skills": [
                {"id": "divergent_fist", "name": "Divergent Fist", "type": "active", "desc": "Pukulan delay cursed energy", "cooldown": 2, "mult": 2.0},
                {"id": "black_flash", "name": "Black Flash", "type": "ultimate", "desc": "Pukulan cursed energy x2.5", "cooldown": 5, "mult": 5.0},
                {"id": "sukuna_vessel", "name": "Sukuna Vessel", "type": "passive", "desc": "20% chance extra attack", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["gojo_satoru", "megumi_fushiguro"],
        },
        {
            "id": "sukuna",
            "hero_name": "Ryomen Sukuna",
            "hero_class": "Assassin",
            "faction": 1,
            "rarity": "UR",
            "anime_origin": "Jujutsu Kaisen",
            "base_hp": 1000, "base_atk": 420, "base_def": 130,
            "base_spd": 135, "base_crit_rate": 0.30, "base_crit_dmg": 2.0,
            "skills": [
                {"id": "cleave", "name": "Cleave", "type": "active", "desc": "Potong musuh sesuai HP", "cooldown": 3, "mult": 3.5},
                {"id": "malevolent_shrine", "name": "Malevolent Shrine", "type": "ultimate", "desc": "Domain expansion, AoE", "cooldown": 6, "mult": 5.5},
                {"id": "king_of_curses", "name": "King of Curses", "type": "passive", "desc": "+30% damage, immune control", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["yuji_itadori"],
        },
        # === KINDRED (Bleach) ===
        {
            "id": "ichigo_kurosaki",
            "hero_name": "Ichigo Kurosaki",
            "hero_class": "Assault",
            "faction": 2,  # KINDRED
            "rarity": "SSR+",
            "anime_origin": "Bleach",
            "base_hp": 1250, "base_atk": 330, "base_def": 185,
            "base_spd": 115, "base_crit_rate": 0.18, "base_crit_dmg": 1.6,
            "skills": [
                {"id": "getsuga_tensho", "name": "Getsuga Tensho", "type": "active", "desc": "Slash energi membelah musuh", "cooldown": 3, "mult": 2.8},
                {"id": "bankai", "name": "Bankai", "type": "ultimate", "desc": "Transformasi, boost stat 60%", "cooldown": 6, "mult": 4.2},
                {"id": "hollow_power", "name": "Hollow Power", "type": "passive", "desc": "Bleed effect pada serangan", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["rukia_kuchiki", "orihime_inoue"],
        },
        {
            "id": "rukia_kuchiki",
            "hero_name": "Rukia Kuchiki",
            "hero_class": "Control",
            "faction": 2,
            "rarity": "SSR",
            "anime_origin": "Bleach",
            "base_hp": 950, "base_atk": 270, "base_def": 150,
            "base_spd": 118, "base_crit_rate": 0.16, "base_crit_dmg": 1.5,
            "skills": [
                {"id": "hakuren", "name": "Hakuren", "type": "active", "desc": "Serangan es freeze musuh", "cooldown": 3, "mult": 2.2},
                {"id": "bankai_hakka", "name": "Hakka no Togame", "type": "ultimate", "desc": "Bankai es, damage masif", "cooldown": 6, "mult": 4.0},
                {"id": "kido", "name": "Kido", "type": "passive", "desc": "Debuff accuracy musuh", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["ichigo_kurosaki"],
        },
        {
            "id": "aizen_sosuke",
            "hero_name": "Aizen Sosuke",
            "hero_class": "Control",
            "faction": 2,
            "rarity": "UR",
            "anime_origin": "Bleach",
            "base_hp": 1050, "base_atk": 310, "base_def": 160,
            "base_spd": 122, "base_crit_rate": 0.22, "base_crit_dmg": 1.7,
            "skills": [
                {"id": "kyoka_suigetsu", "name": "Kyoka Suigetsu", "type": "active", "desc": "Ilusi sempurna", "cooldown": 4, "mult": 2.5},
                {"id": "hogyoku", "name": "Hogyoku", "type": "ultimate", "desc": "Evolusi, boost stat 80%", "cooldown": 8, "mult": 5.0},
                {"id": "hypnosis", "name": "Hypnosis", "type": "passive", "desc": "Musuh 25% chance miss", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": [],
        },
        # === DEMONHUNT (One Piece) ===
        {
            "id": "luffy_monkey",
            "hero_name": "Monkey D. Luffy",
            "hero_class": "Assault",
            "faction": 3,  # DEMONHUNT
            "rarity": "SSR+",
            "anime_origin": "One Piece",
            "base_hp": 1400, "base_atk": 310, "base_def": 200,
            "base_spd": 100, "base_crit_rate": 0.15, "base_crit_dmg": 1.5,
            "skills": [
                {"id": "gum_gum_pistol", "name": "Gum-Gum Pistol", "type": "active", "desc": "Pukulan elastis jarak jauh", "cooldown": 2, "mult": 2.2},
                {"id": "gear_5", "name": "Gear 5", "type": "ultimate", "desc": "Awakening, ubah medan", "cooldown": 7, "mult": 4.8},
                {"id": "rubber_body", "name": "Rubber Body", "type": "passive", "desc": "+20% HP, immune blunt", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["zoro_roronoa", "sanji_vinsmoke"],
        },
        {
            "id": "zoro_roronoa",
            "hero_name": "Roronoa Zoro",
            "hero_class": "Assassin",
            "faction": 3,
            "rarity": "SSR+",
            "anime_origin": "One Piece",
            "base_hp": 1100, "base_atk": 360, "base_def": 160,
            "base_spd": 115, "base_crit_rate": 0.28, "base_crit_dmg": 1.9,
            "skills": [
                {"id": "three_sword_style", "name": "Three Sword Style", "type": "active", "desc": "3 pedang, damage tinggi", "cooldown": 3, "mult": 3.2},
                {"id": "asura", "name": "Asura", "type": "ultimate", "desc": "9 pedang ilusi, AoE", "cooldown": 6, "mult": 4.6},
                {"id": "king_of_hell", "name": "King of Hell", "type": "passive", "desc": "Crit +50% saat HP<50%", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["luffy_monkey"],
        },
        {
            "id": "sanji_vinsmoke",
            "hero_name": "Sanji Vinsmoke",
            "hero_class": "Assault",
            "faction": 3,
            "rarity": "SSR",
            "anime_origin": "One Piece",
            "base_hp": 1050, "base_atk": 300, "base_def": 150,
            "base_spd": 120, "base_crit_rate": 0.20, "base_crit_dmg": 1.6,
            "skills": [
                {"id": "diable_jambe", "name": "Diable Jambe", "type": "active", "desc": "Tendangan api, burn", "cooldown": 3, "mult": 2.6},
                {"id": "ifrit_jambe", "name": "Ifrit Jambe", "type": "ultimate", "desc": "Api biru, damage masif", "cooldown": 6, "mult": 4.0},
                {"id": "black_leg", "name": "Black Leg", "type": "passive", "desc": "Tendangan cepat, +speed", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["luffy_monkey", "zoro_roronoa"],
        },
        # === VOID (One Punch Man) ===
        {
            "id": "saitama",
            "hero_name": "Saitama",
            "hero_class": "Assault",
            "faction": 4,  # VOID
            "rarity": "EX",
            "anime_origin": "One Punch Man",
            "base_hp": 2000, "base_atk": 500, "base_def": 300,
            "base_spd": 90, "base_crit_rate": 0.10, "base_crit_dmg": 3.0,
            "skills": [
                {"id": "serious_punch", "name": "Serious Punch", "type": "active", "desc": "Satu pukulan serius", "cooldown": 4, "mult": 8.0},
                {"id": "consecutive_punches", "name": "Consecutive Normal Punches", "type": "ultimate", "desc": "Pukulan bertubi-tubi", "cooldown": 6, "mult": 6.0},
                {"id": "limitless", "name": "Limitless", "type": "passive", "desc": "Tidak bisa mati 1 hit", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": [],
        },
        {
            "id": "genos",
            "hero_name": "Genos",
            "hero_class": "Assault",
            "faction": 4,
            "rarity": "SSR",
            "anime_origin": "One Punch Man",
            "base_hp": 1100, "base_atk": 340, "base_def": 170,
            "base_spd": 110, "base_crit_rate": 0.20, "base_crit_dmg": 1.7,
            "skills": [
                {"id": "incineration_cannon", "name": "Incineration Cannon", "type": "active", "desc": "Laser api membakar", "cooldown": 3, "mult": 3.0},
                {"id": "spiral_incineration", "name": "Spiral Incineration", "type": "ultimate", "desc": "Api spiral, AoE", "cooldown": 6, "mult": 4.5},
                {"id": "cyborg_body", "name": "Cyborg Body", "type": "passive", "desc": "Regen HP per turn", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": ["saitama"],
        },
        {
            "id": "tatsumaki",
            "hero_name": "Tatsumaki",
            "hero_class": "Control",
            "faction": 4,
            "rarity": "UR",
            "anime_origin": "One Punch Man",
            "base_hp": 900, "base_atk": 280, "base_def": 140,
            "base_spd": 130, "base_crit_rate": 0.22, "base_crit_dmg": 1.6,
            "skills": [
                {"id": "psychic_crush", "name": "Psychic Crush", "type": "active", "desc": "Hancurkan dengan telekinesis", "cooldown": 3, "mult": 2.8},
                {"id": "gravity_catastrophe", "name": "Gravity Catastrophe", "type": "ultimate", "desc": "Tarik semua musuh", "cooldown": 7, "mult": 4.2},
                {"id": "esper", "name": "Esper", "type": "passive", "desc": "Control immunity", "cooldown": 0, "mult": 1.0},
            ],
            "bonds": [],
        },
    ]

static func get_template_by_id(template_id: String) -> Dictionary:
    for t in get_all_templates():
        if t["id"] == template_id:
            return t.duplicate(true)
    return {}

static func create_hero_from_template(template: Dictionary) -> Dictionary:
    # Unique per instance: 10x summon in the same frame must not share an id.
    var stamp = int(Time.get_unix_time_from_system() * 1000.0)
    return {
        "id": "%s_%d_%d" % [template["id"], stamp, randi() % 100000],
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
        "awakened": false,
        "copies": 0,
        "skills": template["skills"].duplicate(true),
        "bonds": template["bonds"].duplicate(),
    }
