# UX/UI & Sistem — mengikuti Twilight Chronicle (hasil REA)

Acuan: `TwilightChronicle-REA` (1.134 tabel FlatBuffers + screenshot City &
Hero Summon dari user). Target: Shonen Grand meniru **struktur layar, alur menu,
dan sistem** Twilight — tema/karakter tetap anime crossover.

> Semua nama dari target = **data observasi**.

---

## A. Kerangka layar (shell)

**Top bar (semua layar utama)**
avatar + level · bar energi/stamina · power tim · pill 💎/💰/🎫 dengan tombol `+`.

**City (home)** — sudah ada, perlu dirapikan:
grid tombol fitur berbingkai emas · panggung tengah (CTA campaign + 3 tombol
bangunan) · rail kiri (Share, Guide, Rankings, Friends, Mail) · rail kanan
(Preview, Quest, Bag, Dailies) · kartu idle reward · baris tim · **bottom nav 7 tab**.

**Bottom nav 7 tab** (dari screenshot Twilight: City · Hero · Growth · Campaign ·
Adventure · Contest · Alliance). Peta kita:

| Twilight | Shonen Grand | Isi |
|---|---|---|
| City | **City** | hub |
| Hero | **Hero** | roster, lineup, bonds |
| Growth | **Growth** | grade/awaken/relic/pet (boost global) |
| Campaign | **Campaign** | chapter + stage + quick fight |
| Adventure | **PvE** | Tower, Maze, Trial, Expedition, Astral |
| Contest | **Contest** | Arena, ranking, glory |
| Alliance | **Guild** | guild boss, duel, peak |

---

## B. Daftar layar & sistem (dari 1.134 tabel)

Kelompok tabel → sistem. ✔ = sudah ada, ◐ = sebagian, ✗ = belum.

### 1. Hero (82 tabel) — ◐
`HeroCfg, HeroGradeCfg, HeroLevelCfg/Up, HeroAwaken*, HeroEvolution*,
HeroGodImprintCfg, HeroTagCfg, HeroCampDesCfg, HeroCareerDesCfg, HeroStoryCfg,
HeroModelPaintingCfg, HeroRelationShipCfg`
→ ✔ level cap, grade, awaken · ✗ evolution, god imprint, story, tag/role bonus,
bonds (Fetter) · ◐ bio/skin.

### 2. Summon/Gacha (54) — ◐
`CallCfg, CallProbupCfg, CallCamp*, CallSpecCfg, HundredCallCfg, ChurchPool/
GuaranteeCfg, ExclusiveRaffleCfg, WishHeroListCfg, PetCallPoolCfg,
PreHeroCallBaseCfg, CallScore*`
→ ✔ 4 banner + pity + 10× jaminan · ✗ Church pool, Exclusive raffle, Wish hero,
100-draw bertingkat, pet summon, skor summon.

### 3. Item/Ekonomi (136) — ◐
`PropCfg, PropGradeCfg, PropSourceCfg, PropSellTypeCfg, DecomposeCfg,
ExchangeCfg/Rate, StoreTypeCfg, MarketGoodsCfg, SeaMarketGoodsCfg`
→ ✔ store 3 tab, exchange shard, bag · ✗ decompose, grade prop, market harian
(gold/sea), sell.

### 4. Equipment/Glyph/Rune (81) — ✗
`EquipCfg, EquipAttriCfg, EquipCarve*, NewEquipRefine*, Glyphs*, Rune*`
→ sistem gear + glyph + rune (slot, upgrade, lottery).

### 5. PvE (224) — ◐
`WarChapterCfg/WarCopyCfg/WarQuickFight/WarDropRelatedCfg, MonsterTowerCfg,
MountainTrial*, MazeMapCfg, PagodaBasic/Copy*, AstralSpiritStage*, StellarSpire*,
ShadowSword*, InterStellar*, NeptuneTower*, HallucinationLadder*, Crime*/sinCity,
Expedition*, StoryAdventure*, AdventureMapCfg, DailyInstanceZones*`
→ ✔ campaign, tower, maze, trial · ✗ quick fight, chapter reward, adventure map,
expedition, daily instance, astral/spire/pagoda.

### 6. PvP/Arena (83) — ✗
`ArenaCfg, GloryArenaCfg, NightArenaBaseCfg, TimeArenaCfg, MultiArenaBaseInfoCfg,
HonorComp*, SkyChozen*, ThroneGlory*`
→ arena async + ranking + glory shop.

### 7. Guild/Legion (127) — ✗
`GuildBaseCfg, GuildBoss*, GuildDuel*, GuildExpedition*, GuildPeak*,
GuildInterior*, Legion*`
→ guild + boss + duel + SLG teritorial.

### 8. Pet/Beast/Relic (170) — ✗
`PetBaseCfg/PetAllLevelCfg, BeastBaseCfg/BeastWakeUP, NewRelicsBaseCfg/Relics*,
NewRelicsStrengthenCfg, HolySealCfg, CanyonAltar*, Resonance*, TechTree*,
Divine*, Totem*, ColorTemple*, Collection* (artifact), Commander*`
→ cabang boost global (Growth tab).

### 9. Event (156) — ◐
`Carnival*/LimitCarnival/MergeCarnival, ActivityLuckTurntable*, ActivityScorePlot*,
ActivityWeaponDraw*, HundredCall*, LimitFlipCard*, LimitWishTree*, BloodMoon/
RedMoonTaskCfg, SignRewardCfg, GrowthFundCfg, BundlesCfg, MonthCardCfg,
NewVipCfg/VipPrivilegeCfg, payCfg/gaspayCfg/VouchersPayCfg, FirstCharge*`
→ ✔ daily sign-in · ✗ carnival, turntable, wish tree, blood moon, fund, VIP,
bundles/packs, first charge.

### 10. Sosial (79) — ✗
`ChatCfg, FriendsCfg, Invite*, SocialCircle*, UserHeadCfg, UserTitleCfg,
AnnounceCfg, SysMailCfg, Rank*`
→ teman, chat, mail, ranking, gelar, avatar.

### 11. Sistem (93) — ◐
`GlobalCfg, NewFunctionCfg (urutan unlock), SceneCfg, SkillCfg/SkillEffectCfg,
BuffCfg, BattleCfg, FormationCfg, FetterBaseCfg/FetterAttrCfg, SourceCfg,
EffectCfg, ReqCfg, Offline reward, Guide/Tutorial`
→ ✔ formation 2 baris, buff dasar · ✗ bonds (Fetter), skill effect, tutorial.

---

## C. Mekanisme inti terverifikasi (sumber angka)

| Sistem | Angka | Status |
|---|---|---|
| Summon bobot | 89/8,5/2,5% dan 95/4,5/0,5% | ✔ |
| Summon harga | tiket 120 x1/10, diamond 250/2250 | ✔ |
| Pity | 100 (jaminan tier atas), 10× jaminan tier tengah | ✔ |
| Level cap | 17 tahap, maks 600 (`HeroLevelUpCfg`) | ✔ |
| Grade | 7 tier (`HeroGradeCfg`) | ✔ |
| Awaken | bahan Courage Essence + Soul Crystal | ✔ |
| Bond (Fetter) | +100% / +300% / +500% | ✗ |
| Formasi | depan (1–5) / belakang (6–10), 7 preset | ◐ (2 baris) |
| Reward stage | `104/105/260/101` (exp/gold/material/player-exp) | ◐ |
| Idle/offline | hadiah saat keluar, cap 8 jam | ✔ |

---

## D. Rencana implementasi

**Fase 1 — Shell & navigasi (UX/UI dulu)**
1. Bottom nav 7 tab + route ke layar nyata.
2. Layar baru bergaya Twilight (daftar + kartu + header):
   Mail ✉️ · Friends 👥 · Rankings 🏆 · Dailies 📅 · Events 🎉 · Growth 📈 ·
   Contest ⚔️ · Adventure 🧭 · Guild 🏰 · Pet 🐾 · Relic 🔮 · Bag 🎒.
3. City hub dirapikan: rail kiri/kanan berfungsi, tombol fitur → layar terkait.

**Fase 2 — Sistem dengan logika nyata**
4. Fateful Bonds (pasangan hero → bonus stat).
5. Decompose (jual item → gold/coin) + market harian (gold/sea).
6. Arena async (tim vs tim, ranking, glory shop).
7. Event harian: carnival/turntable sederhana + wish tree.
8. Adventure map + expedition + daily instance.

**Fase 3 — Sistem besar**
9. Equipment/Glyph/Rune, Pet/Beast, Relic/Seal/Resonance/Tech.
10. Guild (boss + duel), VIP/paket (opsional).

**Aturan:** tema & karakter anime crossover dipertahankan; yang ditiru dari
Twilight adalah **tata letak, alur menu, nama fungsi, dan angka ekonomi**.
