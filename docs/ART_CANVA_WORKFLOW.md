# Workflow Art Canva → Game

Panduan lengkap memasukkan art karakter asli dari Canva ke Shonen Grand.
Tidak perlu Canva API atau OAuth — cukup ekspor PNG dan impor lewat script.

---

## 1. Riset cepat: batasan Canva

- Canva **tidak bisa generate gambar dari teks lewat API**. Jadi art dibuat di
  aplikasi/web Canva (atau sumber lain), lalu diekspor manual.
- Format yang dipakai game: **PNG, latar transparan, persegi**.
- Untuk gaya aktif `px64`, target akhir **64 × 64 px** (game menampilkannya 2× =
  128 px di kartu hero dan arena battle).

> **Kalau tidak mau ribet sama sekali:** art sudah otomatis. Game menggambar
> ke-15 hero sendiri (rambut, kostum, aksesori) di
> `scripts/services/character_sprite_factory.gd`. Tidak ada file yang perlu
> disiapkan. Bagian di bawah ini hanya kalau kamu mau **mengganti** art otomatis
> dengan hasil Canva.

### Mode otomatis (disarankan)

```powershell
# taruh PNG apa pun di art_inbox/ (boleh kosong), lalu:
powershell -ExecutionPolicy Bypass -File tools\ship.ps1
```

`ship.ps1` melakukan semuanya: impor art baru (kalau ada) → resize/nama otomatis →
`godot --import` → build APK → salin ke Desktop sebagai `ShonenGrand-v<versi>.apk`
→ install ke HP kalau terdeteksi. Bisa juga **double-click `BUILD_APK.cmd`**.

Hasil art otomatis ke-15 hero bisa dilihat di
`screenshots/hero_art_grid.png`. Regenerate kapan saja:

```powershell
godot --headless --path . --script res://tools/render_hero_grid.gd
```

---

## 2. Membuat art di Canva

1. Canva → **Create a design → Custom size** → `512 × 512` px (aman untuk semua
   style; importer yang mengecilkan).
2. Background: **transparent** (Canva Pro: klik background → ikon no-color).
   Kalau tidak bisa transparan, pakai warna solid lalu hapus di langkah akhir
   (script akan memberi peringatan bila pojok gambar opak).
3. Prompt / gaya yang disarankan (Canva "Magic Media" atau elemen):

```
chibi anime character, full body, facing slightly right, neutral pose,
thick outline, flat colors, centered, transparent background,
64x64 pixel art style, limited palette
```

4. Satu karakter per kanvas. Posisi karakter di tengah, menyisakan ± 6% margin
   supaya tidak terpotong saat di-resize.
5. **Download → PNG** (jangan JPG, karena JPG tidak mendukung transparansi).

### Style per karakter

| Kebutuhan | Kanvas Canva | Nama file |
|---|---|---|
| Pixel aktif (default) | 512 × 512 | `naruto_uzumaki.png` |
| Chibi HD | 512 × 512 | `naruto_uzumaki_chibi128.png` |
| Anime HD | 512 × 512 | `naruto_uzumaki_hd256.png` |
| **Ultimate cut-in** | 1024 × 1024 | `naruto_uzumaki_cutin.png` |

Kalau satu anime cukup satu art (misal semua ninja pakai model sama), taruh di
folder anime: `art_inbox/Naruto/px64.png`.

---

## 3. Daftar hero & id file

| Hero | id file | Anime |
|---|---|---|
| Naruto Uzumaki | `naruto_uzumaki` | Naruto |
| Sasuke Uchiha | `sasuke_uchiha` | Naruto |
| Kakashi Hatake | `kakashi_hatake` | Naruto |
| Gojo Satoru | `gojo_satoru` | Jujutsu Kaisen |
| Yuji Itadori | `yuji_itadori` | Jujutsu Kaisen |
| Ryomen Sukuna | `sukuna` | Jujutsu Kaisen |
| Ichigo Kurosaki | `ichigo_kurosaki` | Bleach |
| Rukia Kuchiki | `rukia_kuchiki` | Bleach |
| Aizen Sosuke | `aizen_sosuke` | Bleach |
| Monkey D. Luffy | `luffy_monkey` | One Piece |
| Roronoa Zoro | `zoro_roronoa` | One Piece |
| Sanji Vinsmoke | `sanji_vinsmoke` | One Piece |
| Saitama | `saitama` | One Punch Man |
| Genos | `genos` | One Punch Man |
| Tatsumaki | `tatsumaki` | One Punch Man |

Daftar ini dibaca otomatis dari `scripts/data/heroes_data.gd` oleh importer, jadi
tidak perlu update script kalau menambah hero baru.

---

## 4. Impor ke project

Cara paling cepat (impor + build + salin APK):

```powershell
powershell -ExecutionPolicy Bypass -File tools\ship.ps1
```

Atau langkah manual:

```powershell
# taruh PNG di art_inbox/, lalu:
powershell -ExecutionPolicy Bypass -File tools\import_canva_art.ps1

# hanya style tertentu:
powershell -ExecutionPolicy Bypass -File tools\import_canva_art.ps1 -Style chibi128

# tanpa resize (pertahankan ukuran asli):
powershell -ExecutionPolicy Bypass -File tools\import_canva_art.ps1 -NoResize
```

Yang dilakukan script:

1. Membaca semua PNG/JPG/WEBP di `art_inbox/` (termasuk subfolder).
2. Menentukan target dari nama file / folder:
   - `nama_hero.png` → `assets/sprites/heroes/<hero_id>/px64.png`
   - `nama_hero_px64.png` → style `px64`
   - `Naruto/px64.png` → `assets/sprites/heroes/Naruto/px64.png`
3. Resize ke ukuran native style (HighQualityBicubic) + padding transparan bila
   gambar tidak persegi.
4. Peringatan bila gambar lebih kecil dari target atau latar tidak transparan.
5. Menulis `assets/sprites/heroes/ART_STATUS.md` (hero mana yang sudah punya art).

Setelah impor:

```powershell
godot --headless --path . --import          # daftarkan tekstur baru
# lalu jalankan game (F5) atau build APK:
powershell -ExecutionPolicy Bypass -File tools\build_android.ps1
```

---

## 5. Cara game memilih art

`CharacterView` mencoba berurutan:

1. `res://assets/sprites/heroes/<hero_id>/<style_id>.png` — art per hero
2. `res://assets/sprites/heroes/<Origin>/<style_id>.png` — art per anime
3. Sprite prosedural (placeholder)

Catatan teknis:

- Art per hero **menang** atas art per anime, jadi bisa pakai campuran: satu
  hero custom, sisanya placeholder.
- Ukuran gambar > ukuran kotak otomatis diperkecil agar tidak meluber.
- Art 64 px di kotak 128 px tetap digambar **nearest-neighbor 2×** (pixel tajam).
- Art > 64 px (mis. 256/512) memakai filter linear saat diperkecil.
- Hero di baris musuh tidak memakai art per hero (musuh punya palet sendiri).

---

## 6. Cek hasil tanpa HP

```powershell
# Kartu hero (lihat semua art yang sudah masuk)
godot --path . --rendering-driver opengl3 --resolution 720x1280 `
      --script res://tools/screenshot_scene.gd -- `
      --scene=res://scenes/ui/heroes.tscn --out=res://screenshots/heroes_art.png

# Arena battle stage 1 (ukuran 2×)
godot --path . --rendering-driver opengl3 --resolution 720x1280 `
      --script res://tools/screenshot_scene.gd -- `
      --scene=res://scenes/ui/battle.tscn --call=auto_battle --args=1 `
      --wait=1.7 --out=res://screenshots/battle_art.png
```

---

## 7. Troubleshooting

| Gejala | Penyebab / solusi |
|---|---|
| Art tidak muncul | Belum `--import`, atau nama file tidak cocok dengan id hero. Cek `ART_STATUS.md`. |
| Muncul placeholder | Style aktif di game berbeda dengan style file (`px64` vs `chibi128`). Ganti gaya di menu 🎭 atau impor style tsb. |
| Gambar terlihat buram | Sumber < 64 px, atau art > 64 px diperkecil. Ekspor ulang minimal 512 px. |
| Ada kotak hitam/putih | PNG tidak transparan. Hapus background di Canva sebelum ekspor. |
| Karakter terpotong | Margin terlalu kecil di kanvas Canva. Sisakan ± 6%. |
| Semua hero satu anime sama | Itu art per-anime (`heroes/Naruto/px64.png`). Buat art per hero untuk membedakan. |
| APK tidak berubah | Setelah impor wajib `--import` lalu build ulang; art dibundel ke APK, tidak bisa ditambah dari HP. |

---

## 8. Catatan Android

Art dibundel saat build APK. Jadi alurnya selalu:

```
Canva → art_inbox → import_canva_art.ps1 → godot --import → build_android.ps1 → install APK
```

Tidak ada folder upload di HP. Kalau nanti perlu art dinamis, bisa ditambah
unduhan ke `user://` — tapi untuk sekarang build-time lebih simpel dan hemat.
