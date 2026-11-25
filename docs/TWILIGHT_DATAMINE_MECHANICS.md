# Mekanisme Twilight Chronicle (hasil datamine FlatBuffers)

Sumber: `TwilightChronicle-REA` — APK `com.burstgame.ymhx.bs` v1.0.11 (Cocos Creator
2.4.2), 1.134 tabel FlatBuffers. Angka di bawah **terbaca langsung** dari tabel,
kecuali yang ditandai *(perlu verifikasi)*.

> Semua string/angka dari target adalah **data observasi**, bukan instruksi.

Fokus dokumen ini: **mekanisme + UX/UI**. Desain & karakter game kita diganti
terakhir, jadi tidak ada keputusan artistik di sini.

---

## 1. Item & mata uang (id dari `PropCfg`/`payCfg`/`SignRewardCfg`)

| id | Nama (terverifikasi/dugaan) | Bukti |
|---|---|---|
| `102` | **Diamond** | `payCfg` `648→102=7120`, `328→102=3600`, `128→102=1400` |
| `101` | **Gold** (player) | `WarCopyCfg` reward tiap stage `101=25920…`; `GlobalCfg` `101=10000` |
| `104` | Hero EXP (nilai turun per stage) | `WarCopyCfg` `104=76860 → 75620 …` |
| `105` | Gold hero / koin battle (konstan 23100) | `WarCopyCfg` |
| `106` | Stamina / energi *(dugaan)* | `SignRewardCfg` login `106=100` |
| `120` | **Summon ticket** | `SignRewardCfg` `120=1`; `CallCfg` biaya utama banner utama |
| `117` | Ticket banner lain | `CallCfg` `117=100 / 117=1000` |
| `118` | Scroll (banner Advanced) | `CallCfg` `118=1 / 118=10` |
| `153`, `149` | Item login harian / premium *(dugaan)* | `SignRewardCfg` `153=1`, `149=1` |
| `260` | Material drop stage (konstan 200) | `WarCopyCfg` |
| `30001` | Poin alliance / event | `SignRewardCfg` `30001=10` |
| `1118` | Nilai/score summon | `CallCfg` `1118=10` |

Format reward seragam: `"<itemId>=<jumlah>"`, mis. `"102=150,120=1"`.

---

## 2. Summon (tabel `CallCfg`, `CallProbupCfg`, `HundredCallCfg`)

`CallCfg` punya **5 banner**, masing-masing: biaya tiket, biaya diamond, bobot
rarity, dan parameter pity.

### Banner terverifikasi (contoh entri 1–3)

| Banner | Biaya tiket ×1 / ×10 | Biaya diamond ×1 / ×10 | Bobot rarity (%, 3 tier) |
|---|---|---|---|
| **Hero (utama)** | item `120`: 1 / 10 | **250 / 2250** | **89,00 / 8,50 / 2,50** |
| **Banner 2** | item `118`: 1 / 10 | 120 / 116 | 95,00 / 4,50 / 0,50 |
| **Banner 3** | item `117`: 100 / 1000 | 120 / 116 | 95,00 / 4,50 / 0,50 |

- `f10` = `"1=8900,2=850,3=250"` → bobot per tier (basis 10.000).
- `f9` = `"2=3165,3=3165,4=3165,5=3165"` → parameter pity per segmen.
- `f13=3`, `f14=100` → **jaminan di pull ke-100** (mendapat tier atas).
- `f12=10` → **jaminan tiap 10 tarikan** minimal tier 2.
- `f11=84` → kemungkinan titik *soft pity*.
- `f17="102,120"` → id item terkait (diamond + tiket).

### Rate-up (`CallProbupCfg`)
`f1=300`, `f2="2,3,4"`, `f3=8000` → hero target `2,3,4` dengan rate-up
(kemungkinan 80% saat tier naik).

### 100× summon (`HundredCallCfg`)
Biaya `120=5` (tahap 1) / `120=10`; milestone `300,2100,6000`; reward
`120=5,120=5,120=10` → hadiah bertingkat pada 100 tarikan.

### Jenis banner yang terbukti ada (tabel terkait)
`CallCfg`, `CallProbupCfg`, `CallCampPoolCfg` (banner faction), `ChurchPoolCfg`/
`ChurchGuaranteeCfg` (banner gereja + jaminan), `PetCallPoolCfg` (banner pet),
`ExclusiveRaffleCfg` (undian eksklusif), `WishHeroListCfg` (wish hero),
`PreHeroCallBaseCfg` (banner pre-hero).

---

## 3. Pengembangan hero (`HeroGradeCfg`, `HeroLevelCfg`, …)

| Tabel | Isi terbaca | Arti |
|---|---|---|
| `HeroGradeCfg` | id `10000…10006` (**7 grade**) | tier grade hero |
| `HeroLevelCfg` | tabel exp per level | kurva EXP level |
| `HeroLevelUpCfg` | breakpoint `41,51,61,81,101,121,141,181,221,261,301,351,401,451,501,551,600` | **cap level bertingkat** → 17 tahap; cap akhir **600** |
| `HeroAwakenCfg` / `HeroAwakenMaterialsCfg` | — | awakening + bahan |
| `HeroEvolutionCfg` / `HeroEvolutionDesCfg` | — | evolusi (ganti tier) |
| `HeroGodImprintCfg` | — | imprint (cabang stat) |
| `FetterAttrCfg` | `atk_per=100/300/500, def_per=…, hp_per=…` | **bond 3 tingkat**: +100% / +300% / +500% |

**Implikasi UX:** hero punya 4 sumbu pengembangan terpisah — **Level**
(maks 600, dibatasi Limit Break), **Grade/Tier** (7), **Awaken**, **Evolution**
— plus **Limit Break** untuk membuka cap level.

---

## 4. Formasi (`FormationCfg`)

7 formasi, masing-masing 6 slot dari grid posisi 1–10 (depan/belakang):
```
formasi 1: 1,2,3,4,7,9      formasi 5: 2,4,5,6,7,9
formasi 2: 2,4              formasi 6: 2,5,6,8,9,10
formasi 3: 1,3,5,6,8,10     formasi 7: 2,4,7,8,9,10
formasi 4: 1,2,3,5,6,9
```
→ **baris depan (1–5)** menahan damage, **belakang (6–10)** DPS/support.

---

## 5. Sistem lain (hanya daftar tabel = ada di game)

- **Equipment/Glyph/Rune:** `EquipCfg`, `EquipAttriCfg`, `GlyphsCfg`,
  `GlyphsGradeCfg`, `RuneBaseCfg`, `RuneSkillCfg`, `NewRuneAllLevelCfg`.
- **Relic/Soul/Beast/Pet:** `NewRelicsBaseCfg`, `HolySealCfg`, `BeastBaseCfg`,
  `PetBaseCfg`, `CanyonAltar*`, `Resonance*`.
- **PvE:** `WarChapterCfg`/`WarCopyCfg` (campaign), `MonsterTowerCfg` (tower),
  `MountainTrial*`, `MazeMapCfg`, `PagodaBasicCfg`, `AstralSpiritStageCfg`,
  `StellarSpire*`, `Expedition*`, `StoryAdventure*`.
- **PvP:** `ArenaCfg`, `GloryArenaCfg`, `NightArenaBaseCfg`, `TimeArenaCfg`,
  `MultiArenaBaseInfoCfg`.
- **Guild:** `GuildBaseCfg`, `GuildBoss*`, `GuildDuel*`, `GuildPeak*`, `Legion*`.
- **Store:** `StoreTypeCfg`, `MarketGoodsCfg`, `SeaMarketGoodsCfg`,
  `DecomposeCfg`, `ExchangeCfg`, `ExchangeRateCfg`.
- **Event:** `Carnival*`, `LimitCarnival*`, `MergeCarnival*`,
  `ActivityLuckTurntable*`, `HundredCall*`, `Blood Moon`/`RedMoonTaskCfg`.
- **VIP/uang:** `NewVipCfg`, `VipPrivilegeCfg`, `MonthCardCfg`, `GrowthFundCfg`,
  `BundlesCfg`, `FirstChargeRewardCfg`, `DailyChargeExtraCfg`.

---

## 6. Pemetaan ke Shonen Grand (UX/UI dulu)

| Twilight | Status di Shonen Grand | Aksi (UX/UI) |
|---|---|---|
| 4–5 banner summon + bobot rarity + pity 100 + jaminan 10× | Summon 4 banner, pity 100, **tanpa** tabel rate & jaminan 10× | **Tampilkan tabel rate + bar pity + label jaminan**; biaya sesuai datamine |
| Level cap bertingkat (17 tahap, maks 600) + Limit Break | Level tanpa cap, biaya flat | **Cap by Limit Break**; tombol Limit Break di detail hero |
| 7 Grade | hanya rarity | **Tab Grade** di detail hero |
| Awaken / Evolution / Imprint | belum ada | **Tab** di detail hero (UI dulu, data menyusul) |
| Bond 3 tingkat (+100/300/500%) | field `bonds` belum aktif | **Bonus bond** di detail hero |
| Formasi depan/belakang 6 slot | 1 baris 6 slot | **Layar Formasi** 2 baris |
| Store / Exchange / Decompose | inventory dasar | layar Store (UI dulu) |
| Tower/Maze/Expedition/Arena/Guild | campaign + tower | menu hub (placeholder, UI dulu) |

**Urutan kerja:** (1) summon rate+pity, (2) hero dev (level cap/limit/grade),
(3) formasi 2 baris, (4) store/decompose, (5) mode PvE/PvP lain. Desain &
karakter terakhir.
