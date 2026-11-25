# Roster Hero — 64 karakter (final list)

Sumber: *Hero Tier Builder* milik user (64 slot, 7 tier). SSR+ terbagi dua
(16 core + 8). Faction: Void / Arcane / Kindred / Demonhunt / Lightforged.
Class: Assault / Assassin / Guard / Support / Control.

Diimplementasikan di `scripts/data/heroes_data.gd` (`ROSTER`).

## EX (8)
| Hero | Class | Faction | Anime |
|---|---|---|---|
| Sukuna | Assault | Void | Jujutsu Kaisen |
| Hashirama | Support | Void | Naruto |
| Naruto Six Path | Assault | Void | Naruto |
| Yhwach | Control | Void | Bleach |
| Final Form Ichigo | Assassin | Void | Bleach |
| Blast | Support | Void | One Punch Man |
| Kaido | Guard | Void | One Piece |
| Goku | Assault | Void | Dragon Ball |

## UR (8)
Kaguya (Support/Void) · Sasuke Indra (Assassin/Void) · Aizen Final Form
(Control/Void) · Gojo (Assault/Void) · Luffy 5th Gear (Guard/Void) ·
Garou Cosmic (Assassin/Void) · Saitama Serious (Assassin/Void) ·
Urahara (Support/Void)

## SSR+ core (16)
Itachi (Control/Arcane) · Tsunade (Support/Lightforged) · Minato
(Assassin/Lightforged) · Obito (Control/Demonhunt) · Madara (Guard/Arcane) ·
Byakuya (Control/Lightforged) · Ulquiorra (Assassin/Demonhunt) · Ichigo
(Assassin/Lightforged) · Zoro (Assault/Kindred) · Law (Support/Arcane) ·
Blackbeard (Guard/Demonhunt) · Mihawk (Assassin/Kindred) · Genos
(Assault/Arcane) · Yamamoto (Control/Kindred) · Yuta (Assault/Demonhunt) ·
Levi (Assassin/Kindred)

## SSR+ (8)
Jiraiya (Support/Arcane) · Gaara (Guard/Arcane) · Pain (Assault/Arcane) ·
Starrk (Assault/Demonhunt) · Grimmjow (Assassin/Demonhunt) · Sanji
(Assault/Kindred) · Big Mom (Guard/Kindred) · Bang (Guard/Lightforged)

## SSR (8)
Naruto Shippuden (Assault/Arcane) · Kakashi (Assassin/Arcane) · Might Guy
(Guard/Kindred) · Toshiro (Control/Demonhunt) · Renji (Assault/Demonhunt) ·
Unohana (Support/Lightforged) · Ace (Assault/Kindred) · Megumi
(Control/Demonhunt)

## SR (8)
Neji (Guard/Arcane) · Rock Lee (Assault/Kindred) · Shikamaru (Control/Arcane) ·
Rukia (Control/Demonhunt) · Chad (Guard/Kindred) · Usopp (Support/Kindred) ·
Franky (Guard/Kindred) · Yuji (Assault/Demonhunt)

## R (8)
Sakura (Support/Arcane) · Hinata (Support/Lightforged) · Uryu
(Assassin/Lightforged) · Chopper (Support/Kindred) · King (Guard/Kindred) ·
Fubuki (Control/Arcane) · Nobara (Assassin/Demonhunt) · Tanjiro
(Assault/Demonhunt)

---

## Implementasi
- **Rarity 7 tier**: N → R → SR → SSR → SSR+ → UR → EX (warna kartu di
  `GameConfig.RARITY_COLORS`).
- Summon tetap 3 bucket bobot: **N–SSR (89%) / SSR+ (8,5%) / UR–EX (2,5%)**.
- Stat dasar per rarity × modifier class (Guard tanky, Assassin crit, dst.).
- Skill per class (active + ultimate + passive) dengan nama ber-prefix hero,
  mis. `Sukuna: Overdrive`.
- Starter: Naruto Shippuden, Rukia, Zoro.
- Art prosedural per-anime (Naruto, One Piece, Bleach, Jujutsu Kaisen, One Punch
  Man, Dragon Ball, Attack on Titan, Demon Slayer). Detail unik per hero
  (desain) menyusul di tahap akhir.
