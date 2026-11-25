# Panduan Animasi & Battle Playback

Dokumen ini menjelaskan sistem animasi karakter dan playback pertarungan di
Shonen Grand versi 0.2.x. Semua animasi **dibuat prosedural** dari portrait
64 × 64, jadi belum perlu file sprite sheet.

---

## 1. Clip animasi

| Clip | Frame | FPS | Loop | Isi |
|------|-------|-----|------|-----|
| `idle` | 4 | 4 | ✅ | Napas naik-turun 1 px (64 native) |
| `attack` | 6 | 14 | ❌ | Wind-up → flash → lunge + slash arc + speed lines → recover |
| `hurt` | 3 | 12 | ❌ | Flash putih → goyang kiri (tint merah) → goyang kanan |
| `victory` | 4 | 6 | ❌ | Lompat kecil + sparkle |

Definisi clip ada di `scripts/services/character_sprite_factory.gd` (`ANIMS`),
dipakai bersama oleh `CharacterView` dan layar battle.

Frame dihasilkan dari portrait statis yang sama:

```
make_image()            → portrait dasar
make_anim_image(anim, frame)
  ├─ _shift()           → offset lunge / bob / shake
  ├─ _flash() / _tint() → flash putih, tint merah saat kena hit
  ├─ _slash()           → arc serangan
  └─ _victory_frame()   → hop + sparkle
make_anim_texture()     → ImageTexture, di-cache per (gaya, origin, clip, frame)
```

Karena memakai cache global, frame hanya digambar sekali per kombinasi. Untuk
`px64` dengan 7 origin, total ± 119 tekstur 64 × 64 (≈ 2 MB), aman untuk HP.

---

## 2. CharacterView

`scripts/ui/character_view.gd` (dipakai kartu hero, tim, battle, style studio):

```gdscript
var view := CharacterView.new()
view.style_id = "px64"
view.anime_origin = "Naruto"
view.flip_h = false          # musuh: true (menghadap kiri)
view.animate_idle = true     # hanya di arena battle
add_child(view)

view.play("attack")          # one-shot, otomatis balik ke idle
```

- `animate_idle = false` (default) → kartu/list tetap statis (hemat CPU).
- `flip_h` mencerminkan gambar untuk baris musuh.
- Skala pixel tetap bilangan bulat (`floor(box / 64)`).
- Art asli di `res://assets/sprites/heroes/<Origin>/<style>.png` tetap dipakai
  sebagai frame tunggal (animasi prosedural otomatis nonaktif untuk hero itu).

---

## 3. Battle playback

`BattleEngine.simulate_battle()` sekarang mengembalikan `events` per pukulan:

```gdscript
{
  "round": 3, "side": "player", "actor": 1, "target": 0,
  "damage": 423, "crit": true, "mult": 2.5, "killed": false
}
```

Hasil akhir tetap deterministik dan berisi `player_hp`, `enemy_hp`,
`player_max_hp`, `enemy_max_hp` untuk sinkronisasi HP bar.

`battle_ui.gd` memutar event tersebut:

1. Unit penyerang `play("attack")`, unit target `play("hurt")`.
2. HP bar target turun sesuai damage.
3. Angka damage muncul di atas target (oranye + `!` untuk crit, jitter supaya
   tidak menumpuk, naik lalu memudar).
4. Unit yang mati diberi tint gelap; pemenang `play("victory")`.
5. Durasi total dibatasi ± 7 detik: `delay = clamp(7 / jumlah_event, 0.04, 0.3)`.
6. Tombol **⏩ Lewati** mempercepat ke hasil akhir.

Ukuran unit adaptif: **128 px (2×) kalau tim ≤ 5 unit**, **64 px (1×) kalau 6
unit** supaya enam hero tetap muat satu baris. Ada glow radial di arena supaya
latar tidak kosong.

---

## 4. Mengganti dengan sprite sheet asli (Canva)

Saat art asli siap, buat sheet horizontal dengan urutan frame:

```
idle  | frame 0..3
attack| frame 0..5
hurt  | frame 0..2
victory| frame 0..3
```

Simpan sebagai `res://assets/sprites/heroes/<Origin>/px64_sheet.png`
(64 × N px, tanpa padding antar frame). Implementasi `AnimatedSprite2D`
tinggal mengganti `CharacterView` internal: set `SpriteFrames` dari
`AtlasTexture` per frame — API publik (`play`, `flip_h`, `style_id`) tidak
berubah.

---

## 5. Tes & screenshot

```powershell
# Smoke test: battle penuh + cek HP bar, animasi idle, notice tim kosong
godot --headless --path . res://tools/test_battle_flow.tscn

# Screenshot tengah pertarungan (stage 1)
godot --path . --rendering-driver opengl3 --resolution 720x1280 `
      --script res://tools/screenshot_scene.gd -- `
      --scene=res://scenes/ui/battle.tscn --call=auto_battle --args=1 `
      --wait=1.7 --out=res://screenshots/battle_anim.png

# Screenshot hasil akhir (tunggu playback selesai)
... --call=auto_battle --args=1 --wait=9 --out=res://screenshots/battle_victory.png
```
