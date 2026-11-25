# Shonen Grand (Godot 4)

**Shonen Grand** adalah game Idle RPG berbasis Godot 4 dengan tema anime — menggabungkan elemen dari Naruto, One Piece, Bleach, One Punch Man, dan Jujutsu Kaisen.

## 🎮 Tech Stack
- **Engine:** Godot 4.3+
- **Bahasa:** GDScript
- **Platform Target:** Android (utama), Windows, Web
- **Visual:** 2D

## 📁 Struktur Project
```
shonen-grand-godot/
├── project.godot
├── assets/          # Sprite, audio, font
├── scenes/          # Scene files (.tscn)
│   ├── main.tscn    # Main menu
│   └── ui/          # UI scenes (home, heroes, team, battle, summon, inventory)
├── scripts/
│   ├── autoload/    # GameManager, SceneManager, AudioManager
│   ├── domain/      # Hero, Faction, Battle engine
│   ├── data/        # Hero templates
│   ├── services/    # Canva client, sprite factory, asset importer
│   └── ui/          # UI controllers (termasuk CharacterView)
├── tools/           # Script headless: render sample gaya, screenshot scene
├── docs/            # Panduan gaya karakter & animasi
└── resources/       # Themes, hero data
```

## 🚀 Cara Buka
1. Install Godot 4.3+ dari https://godotengine.org
2. Buka Godot → Import → pilih folder project ini
3. Run (F5)

## 🎯 Fitur yang Sudah Di-port
- ✅ Hero system (13 hero dari 5 anime)
- ✅ 5 Faction dengan advantage system
- ✅ Auto-battle engine (simulate)
- ✅ Idle rewards (gold, exp, ticket)
- ✅ Gacha summon
- ✅ Team builder (6 slot)
- ✅ Upgrade & star up hero
- ✅ Campaign battle dengan enemy scaling
- ✅ Save/load (JSON di user://)
- ✅ 5 opsi gaya tampilan karakter (pixel 16/32/64, chibi HD 128, anime HD 256)
  → lihat [docs/CHARACTER_STYLE_GUIDE.md](docs/CHARACTER_STYLE_GUIDE.md)
- ✅ Preview karakter di kartu hero, tim, dan battle (CharacterView)
- ✅ Animasi idle / attack / hurt / victory (4–6 frame, prosedural)
  → lihat [docs/ANIMATION_GUIDE.md](docs/ANIMATION_GUIDE.md)
- ✅ Battle playback: HP bar per unit, angka damage melayang, crit, skip
- ✅ Starter hero otomatis + hero hasil summon langsung masuk slot tim
- ✅ Art per-hero dari Canva + importer batch (`tools/import_canva_art.ps1`)

## 📱 Export ke Android
1. Project → Export → Add → Android
2. Download Android SDK & keystore
3. Export APK

## 🎨 Asset
Placeholder karakter digambar prosedural (`character_sprite_factory.gd`) dan
otomatis diganti art asli bila file tersedia di:

```
res://assets/sprites/heroes/<hero_id>/<style_id>.png    # per hero (prioritas)
res://assets/sprites/heroes/<Origin>/<style_id>.png     # per anime
```

Alur Canva:

```powershell
# 1. ekspor PNG transparan dari Canva ke art_inbox/ (nama: <hero_id>.png)
powershell -ExecutionPolicy Bypass -File tools\import_canva_art.ps1
godot --headless --path . --import
powershell -ExecutionPolicy Bypass -File tools\build_android.ps1
```

Panduan lengkap: [docs/ART_CANVA_WORKFLOW.md](docs/ART_CANVA_WORKFLOW.md)
Prompt siap pakai 15 hero: [docs/CANVA_PROMPTS.md](docs/CANVA_PROMPTS.md)

Perbandingan 5 gaya: buka **🎭 Gaya Karakter** di game, atau lihat
`assets/sprites/style_samples/`.

## 📄 License
MIT
