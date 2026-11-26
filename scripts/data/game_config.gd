# scripts/data/game_config.gd
# Central balance/economy values taken from the Twilight Chronicle datamine
# (see docs/TWILIGHT_DATAMINE_MECHANICS.md). Keeping them in one place makes it
# easy to retune once the final design/characters land.
extends RefCounted
class_name GameConfig

# ------------------------------------------------------------------ rarity ---
# Seven-tier ladder from the roster. Summon weights still roll 3 pull tiers
# (base / mid / top), so rarities map onto those buckets.
const RARITY_TIERS := {
	"N": 0, "R": 0, "SR": 0, "SSR": 0,
	"SSR+": 1,
	"UR": 2, "EX": 2,
}
const TIER_LABELS := ["N–SSR", "SSR+", "UR/EX"]
const RARITY_ORDER := ["N", "R", "SR", "SSR", "SSR+", "UR", "EX"]
const RARITY_COLORS := {
	"N": Color(0.62, 0.64, 0.70),
	"R": Color(0.48, 0.79, 0.52),
	"SR": Color(0.36, 0.60, 0.95),
	"SSR": Color(0.60, 0.36, 0.95),
	"SSR+": Color(0.25, 0.75, 0.95),
	"UR": Color(0.98, 0.40, 0.75),
	"EX": Color(0.98, 0.75, 0.14),
}


static func rarity_rank(rarity: String) -> int:
	var idx := RARITY_ORDER.find(rarity)
	return idx if idx >= 0 else -1


static func rarity_color(rarity: String) -> Color:
	return RARITY_COLORS.get(rarity, Color(0.6, 0.62, 0.7))

# ------------------------------------------------------------------ summon ---
# per = cost of a single pull in <key> currency.
# weights = [base, mid, top] out of 10_000 (CallCfg.f10).
# pity = pulls before a guaranteed top tier (CallCfg.f14).
# ten_grant = best tier guaranteed by a 10x pull (CallCfg.f12).
const PITY_MAX := 100
const TEN_TIER := 1  # 10x guarantees at least a mid tier (UR)

const BANNERS := [
	{
		"id": "hero", "label": "Hero", "key": "tickets", "unit": "tiket",
		"icon": "🎫", "per": 1, "diamond_per": 250,
		"weights": [8900, 850, 250], "pity": 100, "ten_guarantee": true,
		"pool_tiers": [0, 1, 2], "blurb": "Semua hero, rate-up EX.",
	},
	{
		"id": "friendship", "label": "Friendship", "key": "friendship_points", "unit": "poin",
		"icon": "🤝", "per": 10, "diamond_per": 0,
		"weights": [9500, 450, 50], "pity": 100, "ten_guarantee": false,
		"pool_tiers": [0, 1], "blurb": "Hero dasar untuk duplikat / star up.",
	},
	{
		"id": "advanced", "label": "Advanced", "key": "advanced_scrolls", "unit": "scroll",
		"icon": "📜", "per": 1, "diamond_per": 0,
		"weights": [9500, 450, 50], "pity": 100, "ten_guarantee": true,
		"pool_tiers": [0, 1, 2], "blurb": "Pool lanjutan, jaminan UR tiap 10×.",
	},
	{
		"id": "race", "label": "Race", "key": "diamonds", "unit": "diamond",
		"icon": "💎", "per": 100, "diamond_per": 0,
		"weights": [8900, 850, 250], "pity": 100, "ten_guarantee": true,
		"pool_tiers": [0, 1, 2], "blurb": "Satu faction saja, untuk sinergi bond.",
	},
]

# --------------------------------------------------------------- hero level ---
# HeroLevelUpCfg breakpoints: each entry is the level cap unlocked by one Limit
# Break. Index 0 = starting cap.
const LEVEL_CAPS := [
	40, 50, 60, 80, 100, 120, 140, 180, 220, 260, 300, 350, 400, 450, 500, 550, 600,
]
const MAX_LIMIT_BREAK := 16

# FetterAttrCfg: bond bonus per tier (atk/def/hp as a fraction).
const BOND_TIERS := [
	{"atk": 1.0, "def": 1.0, "hp": 1.0},
	{"atk": 3.0, "def": 3.0, "hp": 3.0},
	{"atk": 5.0, "def": 5.0, "hp": 5.0},
]


# ------------------------------------------------------------------ store ---
# Goods mirror Twilight's Store / Exchange / daily rewards: each entry costs one
# currency and grants one or more of the tracked resources. Costs are economy
# placeholders; retune freely once the design pass lands.
const STORE_TABS := ["gold", "diamond", "exchange"]
const STORE_GOODS := {
	"gold": [
		{"icon": "💠", "name": "Hero Shard ×5", "cost_key": "gold", "cost": 2000, "grant": {"hero_shards": 5}},
		{"icon": "📜", "name": "Advanced Scroll ×1", "cost_key": "gold", "cost": 5000, "grant": {"advanced_scrolls": 1}},
		{"icon": "🤝", "name": "Friendship ×200", "cost_key": "gold", "cost": 1500, "grant": {"friendship_points": 200}},
		{"icon": "🎫", "name": "Ticket ×1", "cost_key": "gold", "cost": 3000, "grant": {"tickets": 1}},
	],
	"diamond": [
		{"icon": "🎫", "name": "Ticket ×5", "cost_key": "diamonds", "cost": 300, "grant": {"tickets": 5}},
		{"icon": "📜", "name": "Advanced Scroll ×5", "cost_key": "diamonds", "cost": 500, "grant": {"advanced_scrolls": 5}},
		{"icon": "💠", "name": "Hero Shard ×50", "cost_key": "diamonds", "cost": 800, "grant": {"hero_shards": 50}},
		{"icon": "💫", "name": "Courage Essence ×20", "cost_key": "diamonds", "cost": 300, "grant": {"courage_essence": 20}},
		{"icon": "🔮", "name": "Soul Crystal ×10", "cost_key": "diamonds", "cost": 600, "grant": {"soul_crystal": 10}},
		{"icon": "🤝", "name": "Friendship ×1000", "cost_key": "diamonds", "cost": 400, "grant": {"friendship_points": 1000}},
	],
	"exchange": [
		{
			"icon": "🎁", "name": "Random Hero (SSR+)",
			"cost_key": "hero_shards", "cost": 100, "grant_hero": true,
		},
		{
			"icon": "⭐", "name": "Star Shard ×1",
			"cost_key": "hero_shards", "cost": 300, "grant": {"star_shards": 1},
		},
	],
}


static func store_tab_label(tab: String) -> String:
	match tab:
		"gold": return "💰 Gold"
		"diamond": return "💎 Diamond"
		"exchange": return "🔁 Exchange"
		_: return tab


# --------------------------------------------------- hero grade / awaken ---
# HeroGradeCfg exposes 7 grade tiers; HeroAwakenCfg is the follow-up branch.
# Grade raises base stats on a flat curve and spends hero shards + gold, awaken
# spends the rare materials (courage essence / soul crystal) for a smaller bump.
const GRADE_COUNT := 7
const AWAKEN_MAX := 5
const GRADE_STEP := 0.08   # +8% base stats per grade
const AWAKEN_STEP := 0.05  # +5% per awaken level


static func grade_mult(grade: int) -> float:
	return 1.0 + float(grade) * GRADE_STEP


static func awaken_mult(awaken: int) -> float:
	return 1.0 + float(awaken) * AWAKEN_STEP


static func grade_cost(grade: int) -> Dictionary:
	return {"gold": 3000 + grade * 2000, "hero_shards": 10 + grade * 10}


static func awaken_cost(awaken: int) -> Dictionary:
	return {"courage_essence": 20 + awaken * 20, "soul_crystal": 5 + awaken * 5}


# -------------------------------------------------------------------- PvE ---
# Mode hub mirrors Twilight's PvE spread: Campaign, Monster Tower, Maze and
# Mountain Trial. Each mode keeps its own floor counter and reward focus.
const PVE_MODES := [
	{"id": "campaign", "name": "Campaign", "icon": "⚔️", "desc": "Stage cerita utama.", "bonus": {}},
	{"id": "tower", "name": "Monster Tower", "icon": "🗼", "desc": "Naik terus tanpa batas. Hadiah Soul Crystal.", "bonus": {"soul_crystal": 2}},
	{"id": "maze", "name": "Maze", "icon": "🌀", "desc": "Labirin stage. Emas berlipat.", "bonus": {}, "gold_mult": 2.0},
	{"id": "trial", "name": "Mountain Trial", "icon": "⛰️", "desc": "Ujian gunung. Hadiah Courage Essence.", "bonus": {"courage_essence": 5}},
]


static func pve_mode(mode_id: String) -> Dictionary:
	for m in PVE_MODES:
		if str(m["id"]) == mode_id:
			return m
	return {}


static func pve_bonus(mode_id: String) -> Dictionary:
	return pve_mode(mode_id).get("bonus", {})


static func pve_gold_mult(mode_id: String) -> float:
	return float(pve_mode(mode_id).get("gold_mult", 1.0))


# ------------------------------------------------------------------ menus ---
# Twilight-style secondary screens. The reusable submenu scene renders
# `title` + `entries`; each entry may jump to another screen via `goto`.
const SUBMENUS := {
	"growth": {
		"title": "📈 Growth",
		"subtitle": "Cabang peningkatan global",
		"entries": [
			{"icon": "⭐", "name": "Grade & Awaken", "desc": "Naikkan tier hero", "goto": "heroes"},
			{"icon": "⚔️", "name": "Gear", "desc": "Equip, glyph, rune", "goto": "gear"},
			{"icon": "♻️", "name": "Decompose", "desc": "Ubah hero spare jadi shard", "goto": "decompose"},
			{"icon": "🔮", "name": "Relic", "desc": "Artefak boost stat", "goto": "menu:relic"},
			{"icon": "🐾", "name": "Pet / Beast", "desc": "Pet pendamping", "goto": "menu:pet"},
			{"icon": "🔷", "name": "Glyph & Rune", "desc": "Ukiran & rune", "goto": "menu:relic"},
			{"icon": "🌳", "name": "Tech Tree", "desc": "Riset permanen", "goto": "menu:relic"},
		],
	},
	"contest": {
		"title": "⚔️ Contest",
		"subtitle": "PvP & peringkat",
		"entries": [
			{"icon": "🏟️", "name": "Arena", "desc": "Tantang tim lain", "goto": "menu:arena"},
			{"icon": "🏆", "name": "Ranking", "desc": "Papan peringkat", "goto": "menu:ranking"},
			{"icon": "🎖️", "name": "Glory Shop", "desc": "Tukar poin kehormatan", "goto": "store"},
			{"icon": "🌙", "name": "Night Arena", "desc": "Arena malam", "goto": "menu:arena"},
		],
	},
	"guild": {
		"title": "🏰 Alliance",
		"subtitle": "Guild & kerja sama",
		"entries": [
			{"icon": "🐲", "name": "Guild Boss", "desc": "Serang boss bersama", "goto": "battle"},
			{"icon": "🤺", "name": "Guild Duel", "desc": "Duel antar guild", "goto": "battle"},
			{"icon": "⛰️", "name": "Guild Peak", "desc": "Pendakian guild", "goto": "menu:guild"},
			{"icon": "👥", "name": "Members", "desc": "Daftar anggota", "goto": "menu:friends"},
			{"icon": "🛒", "name": "Guild Shop", "desc": "Beli dengan poin guild", "goto": "store"},
		],
	},
	"adventure": {
		"title": "🧭 Adventure",
		"subtitle": "Mode ekspedisi",
		"entries": [
			{"icon": "🗼", "name": "Monster Tower", "desc": "Naik terus", "goto": "pve"},
			{"icon": "🌀", "name": "Maze", "desc": "Labirin stage", "goto": "pve"},
			{"icon": "⛰️", "name": "Mountain Trial", "desc": "Ujian gunung", "goto": "pve"},
			{"icon": "🗺️", "name": "Adventure Map", "desc": "Ekspedisi peta", "goto": "pve"},
			{"icon": "🌌", "name": "Astral Spirit", "desc": "Stage astral", "goto": "pve"},
		],
	},
	"mail": {
		"title": "✉️ Mail",
		"subtitle": "Kotak masuk",
		"entries": [
			{"icon": "🎁", "name": "Reward Mail", "desc": "Klaim hadiah", "action": "daily"},
			{"icon": "📢", "name": "Announcements", "desc": "Pengumuman", "goto": "menu:mail"},
			{"icon": "🛡️", "name": "System Mail", "desc": "Pesan sistem", "goto": "menu:mail"},
		],
	},
	"friends": {
		"title": "👥 Friends",
		"subtitle": "Teman & sosial",
		"entries": [
			{"icon": "🤝", "name": "Friend List", "desc": "Daftar teman", "goto": "menu:friends"},
			{"icon": "➕", "name": "Add Friend", "desc": "Cari teman", "goto": "menu:friends"},
			{"icon": "🎫", "name": "Friendship Summon", "desc": "Pakai poin teman", "goto": "summon"},
			{"icon": "💬", "name": "Chat", "desc": "Obrolan", "goto": "menu:friends"},
		],
	},
	"ranking": {
		"title": "🏆 Rankings",
		"subtitle": "Papan peringkat",
		"entries": [
			{"icon": "⚔️", "name": "Power", "desc": "Kekuatan tim", "goto": "menu:ranking"},
			{"icon": "🗼", "name": "Tower", "desc": "Lantai tertinggi", "goto": "menu:ranking"},
			{"icon": "🏟️", "name": "Arena", "desc": "Peringkat arena", "goto": "menu:arena"},
			{"icon": "📊", "name": "Level", "desc": "Level pemain", "goto": "menu:ranking"},
		],
	},
	"dailies": {
		"title": "📅 Dailies",
		"subtitle": "Misi harian & mingguan",
		"entries": [
			{"icon": "🎁", "name": "Sign-in Reward", "desc": "Login harian", "action": "daily"},
			{"icon": "✅", "name": "Daily Missions", "desc": "Misi harian", "goto": "menu:dailies"},
			{"icon": "🗓️", "name": "Weekly", "desc": "Misi mingguan", "goto": "menu:dailies"},
			{"icon": "🏅", "name": "Achievements", "desc": "Pencapaian", "goto": "menu:dailies"},
		],
	},
	"events": {
		"title": "🎉 Events",
		"subtitle": "Event terbatas",
		"entries": [
			{"icon": "🎡", "name": "Carnival", "desc": "Event karnaval", "goto": "menu:events"},
			{"icon": "🎰", "name": "Lucky Turntable", "desc": "Putar hadiah", "goto": "summon"},
			{"icon": "🌳", "name": "Wish Tree", "desc": "Pohon harapan", "goto": "menu:events"},
			{"icon": "🌑", "name": "Blood Moon", "desc": "Event bulan darah", "goto": "menu:events"},
		],
	},
	"pet": {
		"title": "🐾 Pet / Beast",
		"subtitle": "Pendamping tim",
		"entries": [
			{"icon": "🐾", "name": "Pet List", "desc": "Pet yang dimiliki", "goto": "menu:pet"},
			{"icon": "🎰", "name": "Summon Pet", "desc": "Dapatkan pet", "goto": "summon"},
			{"icon": "⬆️", "name": "Pet Level", "desc": "Naikkan level pet", "goto": "menu:pet"},
		],
	},
	"relic": {
		"title": "🔮 Relic & Tech",
		"subtitle": "Boost global",
		"entries": [
			{"icon": "🔮", "name": "Relics", "desc": "Artefak", "goto": "menu:relic"},
			{"icon": "🔱", "name": "Holy Seal", "desc": "Segel suci", "goto": "menu:relic"},
			{"icon": "🌊", "name": "Resonance", "desc": "Resonansi", "goto": "menu:relic"},
			{"icon": "🌳", "name": "Tech Tree", "desc": "Riset", "goto": "menu:relic"},
		],
	},
	"arena": {
		"title": "🏟️ Arena",
		"subtitle": "PvP asinkron",
		"entries": [
			{"icon": "⚔️", "name": "Ranked", "desc": "Bertarung naik peringkat", "goto": "battle"},
			{"icon": "🛡️", "name": "Defense", "desc": "Atur tim bertahan", "goto": "team"},
			{"icon": "🎖️", "name": "Glory Shop", "desc": "Tukar poin", "goto": "store"},
		],
	},
	"vip": {
		"title": "💠 VIP & Paket",
		"subtitle": "Keuntungan & pembelian",
		"entries": [
			{"icon": "💠", "name": "VIP Privileges", "desc": "Keuntungan VIP", "goto": "menu:vip"},
			{"icon": "🗓️", "name": "Month Card", "desc": "Kartu bulanan", "goto": "menu:vip"},
			{"icon": "📈", "name": "Growth Fund", "desc": "Dana pertumbuhan", "goto": "menu:vip"},
			{"icon": "🎁", "name": "Bundles", "desc": "Paket spesial", "goto": "store"},
			{"icon": "⭐", "name": "First Charge", "desc": "Bonus pertama", "goto": "menu:vip"},
		],
	},
}


static func submenu(menu_id: String) -> Dictionary:
	return SUBMENUS.get(menu_id, {})


# ------------------------------------------------------------------- bonds ---
# Fateful Bonds: hero pairs that grant stat bonuses when fielded together.
# tier 0/1/2 maps to BOND_TIERS (+100/+300/+500%).
# Source: FetterBaseCfg / FetterAttrCfg (Twilight datamine).
const BONDS := [
	{"a": "naruto_six_path", "b": "sasuke_indra", "tier": 2},
	{"a": "naruto_six_path", "b": "kaguya", "tier": 2},
	{"a": "naruto_shippuden", "b": "sasuke_indra", "tier": 1},
	{"a": "naruto_shippuden", "b": "sakura", "tier": 1},
	{"a": "naruto_shippuden", "b": "hinata", "tier": 1},
	{"a": "itachi", "b": "sasuke_indra", "tier": 2},
	{"a": "madara", "b": "obito", "tier": 2},
	{"a": "minato", "b": "obito", "tier": 1},
	{"a": "tsunade", "b": "sakura", "tier": 1},
	{"a": "neji", "b": "rock_lee", "tier": 1},
	{"a": "rock_lee", "b": "might_guy", "tier": 2},
	{"a": "shikamaru", "b": "neji", "tier": 1},
	{"a": "gojo", "b": "sukuna", "tier": 2},
	{"a": "gojo", "b": "yuta", "tier": 1},
	{"a": "yuji", "b": "sukuna", "tier": 1},
	{"a": "yuta", "b": "megumi", "tier": 1},
	{"a": "ichigo", "b": "rukia", "tier": 2},
	{"a": "ichigo", "b": "ulquiorra", "tier": 1},
	{"a": "yamamoto", "b": "byakuya", "tier": 1},
	{"a": "yamamoto", "b": "unohana", "tier": 1},
	{"a": "aizen_final", "b": "toshiro", "tier": 1},
	{"a": "luffy_gear5", "b": "zoro", "tier": 2},
	{"a": "luffy_gear5", "b": "ace", "tier": 2},
	{"a": "luffy_gear5", "b": "law", "tier": 1},
	{"a": "sanji", "b": "zoro", "tier": 1},
	{"a": "blackbeard", "b": "law", "tier": 1},
	{"a": "genos", "b": "saitama_serious", "tier": 2},
	{"a": "goku", "b": "saitama_serious", "tier": 1},
	{"a": "kaido", "b": "big_mom", "tier": 1},
]


static func bond_tier(a: String, b: String) -> int:
	for bond in BONDS:
		if (str(bond["a"]) == a and str(bond["b"]) == b) or (str(bond["a"]) == b and str(bond["b"]) == a):
			return int(bond["tier"])
	return -1


static func bond_partners(hero_id: String) -> Array:
	var out := []
	for bond in BONDS:
		if str(bond["a"]) == hero_id:
			out.append({"id": str(bond["b"]), "tier": int(bond["tier"])})
		elif str(bond["b"]) == hero_id:
			out.append({"id": str(bond["a"]), "tier": int(bond["tier"])})
	return out


# ----------------------------------------------------------------- decompose ---
# Twilight DecomposeCfg: convert low-value heroes/items into materials. Costs are
# economy placeholders; shard yield scales with rarity.
const DECOMPOSE_SHARDS := {
	"R": 5, "SR": 15, "SSR": 30, "SSR+": 50, "UR": 80, "EX": 120,
}
const DECOMPOSE_MATERIAL_RATE := 10  # 10 material -> 1 hero shard

# Daily market (Twilight MarketGoods/SeaMarket): a small rotating shop that
# refreshes each day. Each entry may cost gold or diamonds.
const DAILY_MARKET_POOL := [
	{"icon": "🎫", "name": "Ticket ×3", "cost_key": "gold", "cost": 3000, "grant": {"tickets": 3}},
	{"icon": "📜", "name": "Advanced Scroll ×2", "cost_key": "gold", "cost": 4000, "grant": {"advanced_scrolls": 2}},
	{"icon": "💠", "name": "Hero Shard ×20", "cost_key": "gold", "cost": 8000, "grant": {"hero_shards": 20}},
	{"icon": "💫", "name": "Courage Essence ×30", "cost_key": "gold", "cost": 5000, "grant": {"courage_essence": 30}},
	{"icon": "🔮", "name": "Soul Crystal ×15", "cost_key": "gold", "cost": 6000, "grant": {"soul_crystal": 15}},
	{"icon": "🤝", "name": "Friendship ×500", "cost_key": "gold", "cost": 2500, "grant": {"friendship_points": 500}},
	{"icon": "🎫", "name": "Ticket ×10", "cost_key": "diamonds", "cost": 500, "grant": {"tickets": 10}},
	{"icon": "📜", "name": "Advanced Scroll ×10", "cost_key": "diamonds", "cost": 800, "grant": {"advanced_scrolls": 10}},
	{"icon": "💠", "name": "Hero Shard ×100", "cost_key": "diamonds", "cost": 1200, "grant": {"hero_shards": 100}},
	{"icon": "💫", "name": "Courage Essence ×80", "cost_key": "diamonds", "cost": 600, "grant": {"courage_essence": 80}},
	{"icon": "🔮", "name": "Soul Crystal ×40", "cost_key": "diamonds", "cost": 900, "grant": {"soul_crystal": 40}},
]
const DAILY_MARKET_SIZE := 6


static func daily_market_pool() -> Array:
	return DAILY_MARKET_POOL


# -------------------------------------------------------------------- gear ---
# Simplified gear system (Twilight: EquipCfg / GlyphsCfg / RuneBaseCfg). Each
# hero has 4 equip slots + 4 glyph slots + 2 rune slots. Stats stack on top of
# the hero's base stats.
const EQUIP_SLOTS := ["weapon", "armor", "accessory", "boots"]
const EQUIP_SLOT_LABELS := {
	"weapon": "⚔️ Weapon", "armor": "🛡️ Armor",
	"accessory": "💍 Accessory", "boots": "👟 Boots",
}
const GLYPH_COUNT := 4
const RUNE_COUNT := 2

# Base stats per equip rarity (hp/atk/def/spd) before the upgrade level.
const EQUIP_BASE := {
	"N": {"hp": 60, "atk": 18, "def": 12, "spd": 4},
	"R": {"hp": 110, "atk": 32, "def": 22, "spd": 6},
	"SR": {"hp": 180, "atk": 52, "def": 36, "spd": 9},
	"SSR": {"hp": 290, "atk": 82, "def": 58, "spd": 13},
	"SSR+": {"hp": 440, "atk": 125, "def": 88, "spd": 18},
	"UR": {"hp": 660, "atk": 190, "def": 135, "spd": 26},
	"EX": {"hp": 950, "atk": 275, "def": 195, "spd": 36},
}
const EQUIP_UPGRADE_COST := 500  # gold per level
const EQUIP_MAX_LEVEL := 10
const EQUIP_UPGRADE_STAT := 0.12  # +12% per level

# Glyphs: id, name, stat, value (flat). Lottery rolls one of these.
const GLYPHS := [
	{"id": "g_atk", "name": "Attack Glyph", "stat": "atk", "value": 25},
	{"id": "g_def", "name": "Defense Glyph", "stat": "def", "value": 20},
	{"id": "g_hp", "name": "Vitality Glyph", "stat": "hp", "value": 120},
	{"id": "g_spd", "name": "Speed Glyph", "stat": "spd", "value": 8},
	{"id": "g_crit", "name": "Critical Glyph", "stat": "crit", "value": 0.03},
]
const GLYPH_LOTTERY_COST := 200  # gold

# Runes: id, name, skill (passive id), desc.
const RUNES := [
	{"id": "r_power", "name": "Rune of Power", "stat": "atk", "value": 40, "desc": "+40 ATK"},
	{"id": "r_guard", "name": "Rune of Guard", "stat": "def", "value": 35, "desc": "+35 DEF"},
	{"id": "r_life", "name": "Rune of Life", "stat": "hp", "value": 200, "desc": "+200 HP"},
	{"id": "r_swift", "name": "Rune of Swift", "stat": "spd", "value": 12, "desc": "+12 SPD"},
]
const RUNE_CRAFT_COST := 300  # gold


static func level_cap(limit_break: int) -> int:
	var idx := clampi(limit_break, 0, LEVEL_CAPS.size() - 1)
	return int(LEVEL_CAPS[idx])


static func banner_by_id(banner_id: String) -> Dictionary:
	for b in BANNERS:
		if str(b["id"]) == banner_id:
			return b
	return {}


static func tier_of(rarity: String) -> int:
	return int(RARITY_TIERS.get(rarity, 0))


static func tier_label(tier: int) -> String:
	return TIER_LABELS[clampi(tier, 0, TIER_LABELS.size() - 1)]


## Formats a banner's weights as a human-readable rate line, e.g.
## "SSR 89.0% · UR 8.5% · EX 2.5%".
static func rate_line(banner: Dictionary) -> String:
	var weights: Array = banner.get("weights", [8900, 850, 250])
	var total := 0.0
	for w in weights:
		total += float(w)
	var parts := []
	for i in range(weights.size()):
		var pct := float(weights[i]) / total * 100.0
		parts.append("%s %.1f%%" % [TIER_LABELS[i], pct])
	return " · ".join(parts)
