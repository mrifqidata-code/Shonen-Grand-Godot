# 🎭 Panduan Gaya Tampilan Karakter

Dokumen ini menjelaskan 5 opsi tampilan karakter di **Shonen Grand**, cara memilih,
dan cara mengganti placeholder dengan art asli dari Canva.

Buka di game: **Menu utama → 🎭 Gaya Karakter**.
Pilih opsi → tekan **"Pakai gaya ini"** → pilihan tersimpan otomatis di `user://save.json`
dan langsung dipakai di kartu hero, baris tim, dan daftar musuh di Battle.

---

## 1. Ringkasan 5 opsi

| ID | Nama | Resolusi asli | Tampil di HP | Memori/hero | Filter | Cocok untuk |
|----|------|---------------|--------------|-------------|--------|-------------|
| `px16` | Pixel 16 × 16 | 16 × 16 | ± 96 px (6×) | 1 KB | Nearest | Gaya retro 8-bit, sangat ringan |
| `px32` | Pixel 32 × 32 | 32 × 32 | ± 96 px (3×) | 4 KB | Nearest | Pixel klasik, siluet terbaca |
| `px64` | **Pixel 64 × 64 (aktif)** | 64 × 64 | 64–128 px | 16 KB | Nearest | Pixel detail + outline |
| `chibi128` | Chibi HD 128 × 128 | 128 × 128 | 96–128 px | 64 KB | Linear | **Rekomendasi** anime idle RPG |
| `hd256` | Anime HD 256 × 256 | 256 × 256 | 128–256 px | 256 KB | Linear | Hero besar / splash / 1080p |

Contoh hasil render ada di `assets/sprites/style_samples/` (satu PNG per gaya per anime).

> **Gaya aktif proyek: `px64` (Pixel 64 × 64).** Semua avatar di kartu hero, baris tim,
> daftar musuh, dan layar ini memakai gaya tersebut. Ganti kapan saja lewat layar 🎭.

---

## 2. Jawaban singkat: 16, 32, 64, atau 128?

**Proyek ini memakai 64 px.** 16 dan 32 terlalu kecil, 128/256 hanya kalau mau tampilan
non-pixel (HD).

Alasannya:

- **16 × 16** — kepala cuma sekitar 7 × 7 piksel. Di HP 6 inci, setiap piksel sumber jadi
  blok besar. Wajah, mata, dan kostum **tidak mungkin terbaca**. Hanya masuk akal kalau
  seluruh game bergaya retro (font bitmap, ikon pixel, UI pixel).
- **32 × 32** — siluet mulai jelas, tapi mata masih 1 piksel dan ekspresi tidak terbaca.
- **64 × 64** — titik seimbang untuk pixel art: mata 2 px, outline 1 px, kostum terbaca,
  hanya 16 KB per hero. **Ini yang dipakai sekarang.**
- **128 × 128** — alternatif halus (non-pixel) setara anime chibi modern. Garis halus,
  file 64 KB/hero.
- **256 × 256** — paling tajam, untuk hero card besar / splash 1080p. 256 KB/hero.

Aturan praktis: **resolusi sumber = ukuran tampil × bilangan bulat.** Sprite 64 px
ditampilkan 64 px (1×) atau 128 px (2×) — jangan 96 px (1,5×) karena pixel jadi tidak rata.

---

## 3. Penting: resolusi file ≠ ukuran tampil

Project ini render pada **720 × 1280** dengan stretch mode `canvas_items`.
Di HP 1080 × 1920 semuanya diperbesar **1,5×**.

`CharacterView` mengunci skala pixel art ke bilangan bulat (`floor(box / 64)`),
jadi sprite 64 px selalu digambar 64 px (1×) atau 128 px (2×) — tidak pernah 1,5×.
Saat ini: **kartu hero 128 px (2×)**, **baris tim & musuh di Battle 64 px (1×)**.
Kalau nanti bikin layout baru, beri kotak avatar kelipatan 64 (64, 128, 192)
supaya tetap tajam.

- Pixel art 32 px di kotak 96 px (3×), lalu 1,5× oleh layar → **4,5×** (tidak bulat)
  → tepi pixel bisa tampak tidak rata saat sprite bergerak.
- 64 px di kotak 64 px (1×) → total 1,5× di layar 1080p. Aman.
- 64 px di kotak 128 px (2×) → total 3× di layar 1080p. Aman.

Kalau nanti mau pixel-perfect total, kunci ukuran tampil ke kelipatan bulat
(misal sprite selalu 128 px untuk sumber 64 px) dan matikan smoothing kamera.

---

## 4. Mengganti placeholder dengan art Canva

`CharacterView` otomatis memakai file asli kalau ada, tanpa ubah kode:

```
res://assets/sprites/heroes/<Origin>/<style_id>.png
```

Contoh:

```
res://assets/sprites/heroes/Naruto/chibi128.png
res://assets/sprites/heroes/Jujutsu Kaisen/px64.png
res://assets/sprites/heroes/Bleach/hd256.png
```

`<Origin>` = nilai `anime_origin` di `scripts/data/heroes_data.gd`
(`Naruto`, `One Piece`, `Bleach`, `Jujutsu Kaisen`, `One Punch Man`), `Enemy` untuk musuh.

`<style_id>` = salah satu dari `px16`, `px32`, `px64`, `chibi128`, `hd256`.

Langkah:

1. Generate gambar di Canva (AI image generator) dengan background transparan.
2. Export PNG, ukuran **sama dengan resolusi asli gaya** (mis. 128 × 128 untuk `chibi128`).
3. Simpan ke path di atas.
4. Di Godot, klik kanan file → **Import**:
   - Pixel art: **Filter: Off**, **Mipmaps: Off**, **Compress: Lossless**
   - HD: **Filter: On**, **Mipmaps: Off**, **Compress: Lossless** (atau VRAM Compressed untuk build)
5. Jalankan game — placeholder otomatis tergantikan.

> Saat ini satu file dipakai untuk semua hero dari anime yang sama (karena placeholder
> memang per-anime). Kalau mau **per hero**, ubah satu baris di
> `scripts/ui/character_view.gd` pada `_resolve_texture()` menjadi
> `res://assets/sprites/heroes/<hero_id>/<style_id>.png`.

---

## 5. Animasi per gaya

| Gaya | Metode animasi | Frame per aksi | Catatan |
|------|----------------|----------------|---------|
| `px16` | AnimatedSprite2D sprite sheet | 3–4 | Murah, tapi wajah tidak terbaca |
| `px32` | AnimatedSprite2D sprite sheet | 4–6 | Klasik, butuh pixel-perfect scaling |
| `px64` | AnimatedSprite2D sprite sheet | 6–8 | Paling seimbang untuk pixel |
| `chibi128` | AnimatedSprite2D (sheet) atau tween/bone | 8–12 | Cocok untuk idle "napas" + attack |
| `hd256` | Bone/skeletal (mis. Skeleton2D) atau Live2D-style | — | Paling fleksibel, file terbesar |

Set animasi minimal: `idle`, `attack`, `skill`, `hurt`, `death`.
Untuk idle RPG, animasi idle cukup 2–4 frame loop lambat (0.4–0.8 s/frame).

---

## 6. Cara membandingkan / benchmark

**Di dalam game** (paling gampang):

```
Run (F5) → 🎭 Gaya Karakter → lihat pratinjau → Pakai gaya ini
```

**Render PNG semua gaya** (headless, tanpa buka game):

```powershell
godot --headless --path . --script res://tools/render_style_samples.gd
```

Output: `assets/sprites/style_samples/<style>_<origin>.png`

**Screenshot satu scene UI:**

```powershell
godot --path . --rendering-driver opengl3 --resolution 720x1280 `
      --script res://tools/screenshot_scene.gd -- `
      --scene=res://scenes/ui/character_style.tscn `
      --out=res://screenshots/character_style.png
```

---

## 7. File terkait

| File | Fungsi |
|------|--------|
| `scripts/services/character_sprite_factory.gd` | Daftar gaya + render placeholder prosedural |
| `scripts/ui/character_view.gd` | Komponen avatar (pakai art asli bila ada) |
| `scripts/ui/character_style_ui.gd` | Layar pemilihan gaya |
| `scenes/ui/character_style.tscn` | Scene layar pemilihan gaya |
| `tools/render_style_samples.gd` | Render semua gaya ke PNG |
| `tools/screenshot_scene.gd` | Screenshot scene untuk review layout |
| `scripts/autoload/game_manager.gd` | `get_character_style()` / `set_character_style()` |

---

## 8. Catatan Android

- 6 hero × 128 px = **384 KB** VRAM → sangat aman.
- 6 hero × 256 px = **1,5 MB** → masih aman di HP modern, tapi tidak perlu untuk baris battle.
- Sprite sheet 8 frame mengalikan memori: 128 px × 8 = 512 KB/hero → 6 hero ≈ 3 MB.
- Project sudah mengaktifkan `import_etc2_astc` untuk build Android.
  Untuk pixel art, pertimbangkan **Lossless** agar warna tidak bergeser.
- Hindari tekstur > 1024 px per hero di HP kelas bawah.
