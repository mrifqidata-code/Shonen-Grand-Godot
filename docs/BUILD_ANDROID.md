# Membangun APK Android (Shonen Grand)

Panduan ini mencatat setup yang sudah dipasang di mesin ini dan cara build ulang APK.

## Prasyarat (sudah terpasang)

| Komponen | Path / Versi |
|----------|--------------|
| Godot | `C:\Users\PAB-ACDM-NB2159\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe` |
| JDK 17 | `C:\Program Files\Microsoft\jdk-17.0.21.102-hotspot` |
| Android SDK | `C:\Users\PAB-ACDM-NB2159\AppData\Local\Android\Sdk` (build-tools 36.0.0, platform android-37.0) |
| adb | `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe` |
| Keystore rilis | `shonen_grand.keystore` (alias `shonen_grand`) — **tidak di-commit** |
| Export preset | `export_presets.cfg` → "Android", arm64-v8a, signed |
| Package name | `com.shongrand.game` |

Editor Settings Godot yang dipakai export:

```
export/android/android_sdk_path = "C:/Users/PAB-ACDM-NB2159/AppData/Local/Android/Sdk"
export/android/java_sdk_path    = "C:/Program Files/Microsoft/jdk-17.0.21.102-hotspot"
```

Export template Godot 4.7.2 di `%APPDATA%\Godot\export_templates\4.7.2.stable\`
(`android_debug.apk`, `android_release.apk`, `version.txt`).

## Build

```powershell
powershell -ExecutionPolicy Bypass -File tools\build_android.ps1
```

Hasil: `builds/shonen_grand_release.apk`.

Mode debug (untuk uji cepat / log verbose):

```powershell
powershell -ExecutionPolicy Bypass -File tools\build_android.ps1 -Mode debug
```

Manual (tanpa script):

```powershell
$godot = "C:\...\Godot_v4.7.2-stable_win64.exe"
& $godot --headless --path . --import
& $godot --headless --path . --export-release "Android" "builds/shonen_grand_release.apk"
```

## Install ke HP

1. Aktifkan **Opsi Pengembang → USB Debugging** di HP.
2. Sambungkan kabel, izinkan komputer.
3. Cek perangkat: `adb devices`
4. Install:

```powershell
adb install -r builds\shonen_grand_release.apk
```

Atau copy APK ke HP lalu install manual (aktifkan "Install unknown apps").

## Catatan

- Export release **wajib** pakai keystore yang sama setiap rilis, kalau tidak update
  dari Play Store akan ditolak.
- Password keystore saat ini tersimpan plain text di `export_presets.cfg`
  (`shonen123`). Untuk rilis publik: ganti password, simpan di password manager,
  dan isi lewat Godot Editor (Project → Export → Android) atau environment variable.
- `builds/` dan `*.apk` masuk `.gitignore`.
- Ukuran APK pertama ± 25–40 MB (template Godot + aset).
