# Prompt Siap Pakai untuk Canva (15 Hero)

Salin prompt di bawah ke **Canva → Magic Media** (atau app image generator lain),
lalu ekspor PNG transparan dan impor lewat `tools/import_canva_art.ps1`.
Alur lengkap: [ART_CANVA_WORKFLOW.md](ART_CANVA_WORKFLOW.md).

---

## Setelan dasar (pakai untuk semua hero)

**Kanvas:** 512 × 512 px, background transparan.

**Prompt dasar** — tambahkan deskripsi karakter di belakangnya:

```
chibi anime character, full body, standing idle pose facing slightly right,
thick dark outline, flat cel-shaded colors, limited palette, centered with 6% margin,
transparent background, game sprite, no text, no shadow, clean silhouette
```

**Untuk gaya pixel (px64):**

```
64x64 pixel art sprite, chibi proportions, 1px dark outline, flat colors,
no anti-aliasing, large readable eyes, transparent background, centered,
single character, no text
```

> Hasil Magic Media biasanya 1024 px. Itu tidak masalah — importer mengecilkan ke
> 64 px. Yang penting: **satu karakter**, **background transparan**, **tengah**.

---

## Daftar prompt per hero

### Naruto — `naruto_uzumaki.png`
```
chibi ninja boy, spiky bright blond hair, blue headband with metal plate,
orange and black jumpsuit, whisker marks on cheeks, confident grin
```

### Sasuke — `sasuke_uchiha.png`
```
chibi ninja boy, black spiky hair, dark blue high-collar shirt, white shorts,
red sharingan eyes, cool serious expression, sword on back
```

### Kakashi — `kakashi_hatake.png`
```
chibi ninja man, silver spiky hair, dark mask covering lower face,
headband tilted over left eye, green flak vest, hands in pockets
```

### Gojo — `gojo_satoru.png`
```
chibi sorcerer man, white spiky hair, glowing blue eyes, black blindfold pushed up,
dark high-collar uniform, confident smirk, blue energy sparkles
```

### Yuji — `yuji_itadori.png`
```
chibi high school boy, short pink hair, dark navy uniform with red hood,
athletic build, determined smile, faint cursed energy aura
```

### Sukuna — `sukuna.png`
```
chibi cursed king, pink hair with black markings, four black tattoo lines on face,
bare muscular torso with black tattoos, red eyes, menacing grin
```

### Ichigo — `ichigo_kurosaki.png`
```
chibi soul reaper teen, spiky orange hair, black shihakusho robe,
huge cleaver sword wrapped in bandages, fierce expression
```

### Rukia — `rukia_kuchiki.png`
```
chibi soul reaper girl, short black hair with one strand over face,
black shihakusho robe, white sash, small katana, calm expression
```

### Aizen — `aizen_sosuke.png`
```
chibi soul reaper man, slick brown hair, glasses, black robe with white captain haori,
polite sinister smile, katana at side
```

### Luffy — `luffy_monkey.png`
```
chibi pirate boy, black messy hair, straw hat with red band, red open vest,
blue shorts, huge grin, scar under left eye
```

### Zoro — `zoro_roronoa.png`
```
chibi pirate swordsman, short green hair, three katana at hip, dark green haramaki,
white shirt open, green bandana, stern look
```

### Sanji — `sanji_vinsmoke.png`
```
chibi pirate cook, blond hair covering one eye, black suit, blue shirt, tie,
cigarette, kicking pose with flaming leg
```

### Saitama — `saitama.png`
```
chibi bald hero, plain white cape, yellow gloves and boots, red suit,
blank bored expression, simple round face
```

### Genos — `genos.png`
```
chibi cyborg hero, spiky blond hair, black mechanical arms with glowing orange lines,
black sleeveless top, serious yellow eyes
```

### Tatsumaki — `tatsumaki.png`
```
chibi esper woman, curly green hair, black long-sleeve dress with high collar,
green psychic aura, floating pose, arms crossed
```

---

## Variasi gaya (opsional)

Simpan dengan akhiran style untuk gaya lain, contoh `naruto_uzumaki_chibi128.png`:

| Akhiran file | Ganti bagian prompt dengan |
|---|---|
| `_chibi128` | `chibi anime character, 128x128, soft shading, clean lineart` |
| `_hd256` | `anime key visual, full body, dynamic lighting, detailed shading` |

---

## Cek cepat hasil impor

```powershell
powershell -ExecutionPolicy Bypass -File tools\import_canva_art.ps1
Get-Content assets\sprites\heroes\ART_STATUS.md
```

Lalu lihat hasilnya tanpa HP:

```powershell
godot --path . --rendering-driver opengl3 --resolution 720x1280 `
      --script res://tools/screenshot_scene.gd -- `
      --scene=res://scenes/ui/heroes.tscn --out=res://screenshots/heroes_art.png
```
