# tools/ship.ps1
# One command: import any art waiting in art_inbox/, build the release APK and
# copy it to the Desktop (installing on a connected phone when possible).
#
#   powershell -ExecutionPolicy Bypass -File tools\ship.ps1
#   powershell -ExecutionPolicy Bypass -File tools\ship.ps1 -SkipArt
#   powershell -ExecutionPolicy Bypass -File tools\ship.ps1 -NoCopy
param(
    [switch]$SkipArt,
    [switch]$NoCopy,
    [switch]$NoInstall,
    [string]$Godot = "C:\Users\PAB-ACDM-NB2159\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
)

$ErrorActionPreference = "Stop"
$projectDir = Split-Path -Parent $PSScriptRoot

function Read-Version {
    $presets = Get-Content (Join-Path $projectDir "export_presets.cfg") -Raw
    if ($presets -match 'version/name="([^"]+)"') {
        return $Matches[1]
    }
    return "0.0.0"
}

$version = Read-Version
Write-Host "== Shonen Grand $version ==" -ForegroundColor Cyan

# 1. Art: anything dropped into art_inbox/ is imported automatically.
$inbox = Join-Path $projectDir "art_inbox"
if (-not $SkipArt -and (Test-Path $inbox)) {
    $pending = Get-ChildItem -Path $inbox -Recurse -File |
        Where-Object { $_.Extension -match '^\.(png|jpg|jpeg|webp)$' }
    if ($pending.Count -gt 0) {
        Write-Host "== Import art: $($pending.Count) file(s) ==" -ForegroundColor Cyan
        & powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "import_canva_art.ps1")
        if ($LASTEXITCODE -ne 0) {
            throw "art import failed"
        }
    }
    else {
        Write-Host "== Art: pakai sprite otomatis (tidak ada file baru) ==" -ForegroundColor DarkGray
    }
}

# 2. Build (also runs the Godot resource import step).
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_android.ps1") -Godot $Godot

$apk = Join-Path $projectDir "builds\shonen_grand_release.apk"
if (-not (Test-Path $apk)) {
    throw "Build failed: APK not found at $apk"
}

# 2b. Refuse to ship a stale APK (wrong version name inside the file).
$aapt2 = Join-Path $env:LOCALAPPDATA "Android\Sdk\build-tools\36.0.0\aapt2.exe"
if (Test-Path $aapt2) {
    # aapt2 writes harmless warnings to stderr; keep them from aborting the script.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $badging = & $aapt2 dump badging $apk 2>&1 | Select-String "package:"
    $ErrorActionPreference = $previous
    if ($badging -match "versionName='([^']+)'") {
        $apkVersion = $Matches[1]
        Write-Host "== APK version: $apkVersion ==" -ForegroundColor Cyan
        if ($apkVersion -ne $version) {
            throw "APK version mismatch (wanted $version, got $apkVersion). Hapus builds\shonen_grand_release.apk lalu build ulang."
        }
    }
}

# 3. Copy to Desktop with the version in the file name.
$delivered = ""
if (-not $NoCopy) {
    $desktop = [Environment]::GetFolderPath("Desktop")
    $delivered = Join-Path $desktop "ShonenGrand-v$version.apk"
    Remove-Item $delivered -Force -ErrorAction SilentlyContinue
    Copy-Item $apk $delivered -Force
    Write-Host "== APK: $delivered ==" -ForegroundColor Green
}

# 4. Install on a connected phone, if any.
$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
if (-not $NoInstall -and (Test-Path $adb)) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $device = (& $adb devices 2>&1) | Select-String "device$"
        if ($device) {
            Write-Host "== Install ke HP ==" -ForegroundColor Cyan
            & $adb install -r $apk 2>&1 | Select-Object -Last 3
        }
        else {
            Write-Host "== Tidak ada HP terhubung (APK tetap dibuat) ==" -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "== Install dilewati: $($_.Exception.Message) ==" -ForegroundColor DarkYellow
    }
    $ErrorActionPreference = $previous
}

Write-Host ""
Write-Host "Selesai. Versi $version siap." -ForegroundColor Green
