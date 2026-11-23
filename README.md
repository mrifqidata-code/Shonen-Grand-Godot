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
│   └── ui/          # UI controllers
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

## 📱 Export ke Android
1. Project → Export → Add → Android
2. Download Android SDK & keystore
3. Export APK

## 🎨 Asset
Asset akan di-generate dengan Canva AI. Placeholder sprite menggunakan ColorRect sementara.

## 📄 License
MIT
