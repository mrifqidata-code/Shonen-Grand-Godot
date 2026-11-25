# REA Twilight Chronicle — Sistem, Item, dan Summon

**Status bukti**

| Sumber | Kualitas | Catatan |
|---|---|---|
| Screenshot City + Hero Summon (dari user) | **Tinggi** (UI asli) | Menunjukkan nama fitur, currency, pity, tab summon |
| Google Play / App Store changelog | **Tinggi** (resmi) | Divine Chain, Arche Limit Break, EX Tiamat |
| Situs resmi `ymhx.burstgame.hk.cn` | **Tinggi** (resmi) | Lore hero, faction |
| QooApp pre-register reward | **Tinggi** (resmi) | Daftar item: Advanced Summon Scroll, Courage Essence |
| Guide pihak ketiga (BlueStacks, LDPlayer, dll.) | **Sedang** | Sistem umum, bukan angka pasti |
| APK / data game | **Tidak tersedia** | Belum ada datamining; drop rate & tabel item belum terverifikasi |

> Tanpa APK, angka pasti (drop rate, harga, jumlah item per stage) **tidak bisa**
> dipastikan. Yang di bawah ini adalah struktur sistem + nama item yang terbukti
> muncul di UI/resmi.

---

## 1. Currency & item yang terlihat / terkonfirmasi

| Item | Sumber | Fungsi | Bukti |
|---|---|---|---|
| **Diamond** (💎) | Top-up, quest, mail, event | Mata uang premium: summon, refresh, beli paket | UI: 12.612; reward pre-register 200 |
| **Gold** (🪙) | Idle, campaign, jual item | Upgrade hero, equipment, shop | UI: 574M; reward 100.000 |
| **Advanced Summon Scroll** | Event, mail, shop, reward | Tiket summon banner Advanced | Reward pre-register ×3 |
| **Courage Essence** | Idle, stage, event | Bahan upgrade/limit break (kemungkinan besar) | Reward 50.000 |
| **Noble Insignia** | Summon, event, noble level | Pity point: 1.000 poin = jaminan SSR+ | UI: "Lv.8 Noble Insignia can consume 1000 Points to guarantee Summoning SSR+ Hero" |
| **Hero Exchange Coin / Shard** | Summon duplikat, event | Tukar hero tertentu di Hero Exchange | UI: 63/100 |
| **Soul Crystal** | City building / stage | Upgrade soul / hero passive | Label di City |
| **Beast Spirit** | Beast Spirit building | Sistem pet/beast: buff tim | Label + changelog "New UR Beast Spirit" |
| **Relic / Core / Mirror / Void / Venus / Maid Boost material** | Masing-masing building | Boost stat spesifik (relic, core, mirror, void, dst.) | Grid tombol City |
| **Sacred Rock** | Event/progress | Bahan event "Sacred Rock in progress" | Label City |
| **Dawn Chest / Milestone / Value Fund** | Event & progress pass | Reward bertingkat (chest, milestone, fund) | Label City |
| **Skin token / Limited Event token** | Event | Skin hero & banner terbatas | Label City |
| **Alliance point** | Alliance/Alliance Peak | Kontribusi alliance, reward alliance | Label City |
| **Twilight Shop currency** | Twilight Shop | Beli item harian/mingguan | Label City |
| **Friendship point** | Teman, battle | Summon Friendship | Tab "Friendship Summon" |
| **Race/Faction token** | Event faction | Summon per-race | Tab "Race Summon" |
| **Arena/Citadel token** | PvP | Beli hero/gear PvP | Guide LDPlayer (lineup Citadel Arena) |

### Item yang bisa "dihasilkan" (production loop)

```
Idle (offline)  ──► Gold, EXP hero, Courage Essence, Diamond (kecil)
Campaign stage  ──► Gold, EXP, material boost, scroll (jarang)
Boss/Elite      ──► Soul Crystal, Beast Spirit material, relic shard
Event           ──► Sacred Rock, Dawn Chest, Milestone, skin token
Summon          ──► Hero, duplikat → Hero Exchange coin, Noble Insignia
Alliance        ──► Alliance point → shop alliance
PvP (Citadel)   ──► Arena token → shop PvP
Twilight Shop   ──► tukar currency event ↔ item harian
```

---

## 2. Summon: jenis & fungsi gameplay

| Summon | Biaya | Isi pool | Fungsi dalam gameplay | Bukti |
|---|---|---|---|---|
| **Hero Summon** | Diamond (×1 gratis pertama, ×10 = 2.250 💎 di screenshot) | Semua hero, rate-up terbatas | Sumber utama roster; 10× jaminan SSR+; pity 1.000 poin | Screenshot |
| **Friendship Summon** | Friendship point | Hero rendah–menengah + fodder | Isi duplikat untuk **star up / Arche Limit Break**, hemat diamond | Tab di screenshot |
| **Adv. Summon** | Advanced Summon Scroll | Pool lanjutan (rate lebih tinggi / hero spesifik) | Summon hemat untuk pemain lama; scroll dari event | Tab + reward scroll |
| **Race Summon** | Token race / diamond | Satu faction/race (Lightforged, Kindred, Arcane, Demonhunt, Void) | Fokus membangun tim faction untuk bonus sinergi | Tab di screenshot |
| **Limited / EX Summon** | Diamond / scroll event | 1 hero EX/UR rate-up besar | Chase unit meta (contoh: Tiamat "Astral Terminus") | Changelog resmi |
| **Hero Exchange** | Hero Exchange coin/shard | Hero pilihan | Pity alternatif: tukar duplikat jadi hero incaran | UI 63/100 |

### Kenapa summon dipisah-pisah?

1. **Monetisasi berlapis** — diamond untuk whale, scroll/point untuk F2P.
2. **Fodder economy** — Friendship Summon menyuplai duplikat; duplikat dipakai
   untuk **star up** dan **Arche Limit Break** (changelog: "Consume duplicates to
   awaken ultimate stats and upgrade exclusive skills").
3. **Faction synergy** — Race Summon mendorong pemain membangun 1 faction karena
   **Fateful Bonds** memberi stat boost kalau komposisi cocok.
4. **Pity** — Noble Insignia 1.000 poin menjamin SSR+ sehingga pemain tidak
   frustrasi; ini standar idle RPG.

---

## 3. Sistem progression yang terlihat

| Sistem | Fungsi | Bukti |
|---|---|---|
| **Level & Star Up** | Naikkan stat dasar | UI hero |
| **Limit Break (LB)** | Naikkan cap level & stat | UI hero "LB0" |
| **Arche Limit Break** | Konsumsi duplikat → buka stat ultimate & upgrade skill eksklusif | Changelog v1.5 |
| **Divine Chain** | Link EX + UR/UR+ → passive talent & sinergi | Changelog v1.5 |
| **Fateful Bonds** | Bonus stat kalau pasangan hero ada di tim | Guide + UI |
| **Formation 6 slot** | Posisi 1–6, depan menahan damage, belakang DPS | Guide LDPlayer |
| **Relic/Core/Mirror/Void/Venus/Maid Boost** | Cabang upgrade stat global | Grid City |
| **Beast Spirit** | Pet/beast dengan skill & stat | City + changelog |
| **Soul Crystal** | Upgrade soul/passive | City |
| **Evolution Temple** | Evolve hero (tier/awakening) | City |
| **Alliance Hegemony / Peak** | Guild boss & peringkat | City |
| **Campaign / Adventure / Contest** | PvE campaign, ekspedisi, ranking | Bottom nav |
| **Idle/offline** | Reward saat keluar game (zero-loss) | Deskripsi resmi |

---

## 4. Pemetaan ke Shonen Grand (yang sudah ada vs belum)

| Twilight | Shonen Grand sekarang | Rekomendasi |
|---|---|---|
| Diamond, Gold | ✅ diamonds, gold | Tambah **Advanced Scroll**, **Friendship Point**, **Noble Insignia** |
| Hero Summon | ✅ ticket summon | Ganti biaya jadi diamond/scroll, tambah pity |
| Friendship Summon | ❌ | Implement (fodder untuk star up) |
| Adv. Summon | ❌ | Implement (scroll dari idle/event) |
| Race Summon | ❌ | Implement per-faction (5 faction kita sudah ada) |
| Hero Exchange | ❌ | Implement shard → hero pilihan |
| Level/Star/LB | ✅ level, star, limit_break | Tambah **Arche** (duplikat → skill) |
| Relic/Beast/Soul | ❌ | Nanti: 3 cabang boost global |
| Formation 6 slot | ✅ 6 slot, 1 baris | Tambah **baris depan/belakang** |
| Fateful Bonds | ⚠️ ada field `bonds` | Aktifkan bonus pasangan |
| Campaign | ✅ stage battle | Tambah Adventure/Contest |
| Idle reward | ✅ 8 jam | Tambah drop scroll & material |

---

## 5. Rencana implementasi bertahap

**Tahap 1 — Summon economy (dikerjakan berikut)**
- 4 tab summon: Hero (ticket), Friendship (friend point), Advanced (scroll), Race (diamond + pilih faction).
- Pity: Noble Insignia +1 per pull, 100 → jaminan SSR+.
- Duplikat otomatis jadi Hero Shard (bahan star up).

**Tahap 2 — Item & production**
- Tambah item: `advanced_scroll`, `friendship_point`, `courage_essence`, `soul_crystal`.
- Drop dari battle/idle; tampil di Inventory.

**Tahap 3 — Progression**
- Arche (duplikat → skill), Divine Chain (link 2 hero), Fateful Bonds.
- Relic/Beast/Soul boost.

**Tahap 4 — Mode**
- Adventure (ekspedisi), Contest (ranking), Alliance-style guild boss.