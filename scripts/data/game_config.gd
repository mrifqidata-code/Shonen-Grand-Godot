# scripts/data/game_config.gd
# Central balance/economy values taken from the Twilight Chronicle datamine
# (see docs/TWILIGHT_DATAMINE_MECHANICS.md). Keeping them in one place makes it
# easy to retune once the final design/characters land.
extends RefCounted
class_name GameConfig

# ------------------------------------------------------------------ rarity ---
# Twilight weights 3 pull tiers per banner on a 10_000 basis. Our rarities map
# onto those tiers so the odds shown to the player match the real numbers.
const RARITY_TIERS := {
	"SSR": 0, "SSR+": 0,
	"UR": 1, "UR+": 1,
	"EX": 2,
}
const TIER_LABELS := ["SSR", "UR", "EX"]

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
