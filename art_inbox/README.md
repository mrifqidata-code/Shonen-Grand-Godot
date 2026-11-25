# art_inbox — taruh hasil ekspor Canva di sini

Folder ini **tidak ikut** ke git dan tidak dibundel ke APK. Isinya cuma bahan
mentah sebelum diimpor.

## Cara pakai

1. Ekspor art dari Canva sebagai **PNG, latar transparan**, kanvas persegi.
2. Simpan ke folder ini dengan nama salah satu format:

```
art_inbox/
├── naruto_uzumaki.png              # otomatis jadi px64 (style default)
├── sasuke_uchiha_px64.png          # style ditentukan di nama file
├── gojo_satoru_chibi128.png
├── Naruto/px64.png                 # art level anime (dipakai semua hero Naruto)
└── One Piece/
    ├── px64.png
    └── hd256.png
```

Nama hero harus sama dengan id di `scripts/data/heroes_data.gd`
(contoh: `naruto_uzumaki`, `luffy_monkey`, `ichigo_kurosaki`, `gojo_satoru`).

Style yang valid: `px16`, `px32`, `px64`, `chibi128`, `hd256`.

3. Jalankan:

```powershell
powershell -ExecutionPolicy Bypass -File tools\import_canva_art.ps1
```

Script akan resize ke ukuran native style, cek transparansi, menyalin ke
`assets/sprites/heroes/<hero_id>/<style>.png`, dan menulis laporan ke
`assets/sprites/heroes/ART_STATUS.md`.

4. Impor ulang di Godot lalu build:

```powershell
godot --headless --path . --import
powershell -ExecutionPolicy Bypass -File tools\build_android.ps1
```

## Ukuran kanvas Canva

| Style | Kanvas / ukuran akhir | Tampil di game |
|---|---|---|
| `px64` (aktif) | 64 × 64 | 128 px di kartu & arena |
| `chibi128` | 128 × 128 | 96–128 px |
<|message|> `hd256` | 256 × 256 | 128–256 px |

Ekspor dari Canva boleh lebih besar (512/1024 px) — importer akan mengecilkan.
Jangan mengekspor lebih kecil dari ukuran native, hasilnya pecah.

## Urutan prioritas art

```
assets/sprites/heroes/<hero_id>/<style>.png   ← art per hero (paling spesifik)
assets/sprites/heroes/<Origin>/<style>.png    ← art per anime
placeholder prosedural                         ← fallback
```
