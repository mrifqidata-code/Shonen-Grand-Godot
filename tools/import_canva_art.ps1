# tools/import_canva_art.ps1
# Import Canva character art into the Godot project.
#
# Drop PNG exports into art_inbox/ (subfolders allowed) and run:
#   powershell -ExecutionPolicy Bypass -File tools\import_canva_art.ps1
#
# File naming (case-insensitive, spaces or underscores both work):
#   naruto_uzumaki.png              -> assets/sprites/heroes/naruto_uzumaki/px64.png
#   naruto_uzumaki_px64.png         -> same
#   gojo_satoru_chibi128.png        -> assets/sprites/heroes/gojo_satoru/chibi128.png
#   Naruto/px64.png                 -> assets/sprites/heroes/Naruto/px64.png (per-anime)
#   One Piece/hd256.png             -> assets/sprites/heroes/One Piece/hd256.png
#
# Per-hero art wins over per-anime art, which wins over the procedural sprite.
param(
    [string]$Source = "",
    [ValidateSet("px16", "px32", "px64", "chibi128", "hd256", "cutin")]
    [string]$Style = "px64",
    [switch]$NoResize
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$projectDir = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Source)) {
    $Source = Join-Path $projectDir "art_inbox"
}

$styleNative = @{ px16 = 16; px32 = 32; px64 = 64; chibi128 = 128; hd256 = 256; cutin = 512 }
$styleIds = @("px16", "px32", "px64", "chibi128", "hd256", "cutin")

function Normalize-Key([string]$value) {
    return ($value.ToLower() -replace '[\s_\-]', '')
}

# ---- read the hero manifest straight from GDScript -------------------------
$heroesFile = Join-Path $projectDir "scripts\data\heroes_data.gd"
if (-not (Test-Path $heroesFile)) {
    throw "heroes_data.gd not found: $heroesFile"
}
$heroText = Get-Content $heroesFile -Raw
$rx = [regex]'(?s)"id":\s*"([a-z0-9_]+)",\s*"hero_name":\s*"([^"]+)",[^}]*?"anime_origin":\s*"([^"]+)"'
$heroes = [ordered]@{}
foreach ($m in $rx.Matches($heroText)) {
    $heroes[$m.Groups[1].Value] = @{
        name   = $m.Groups[2].Value
        origin = $m.Groups[3].Value
    }
}
if ($heroes.Count -eq 0) {
    throw "No hero templates parsed from heroes_data.gd"
}

$origins = @{}
foreach ($hero in $heroes.Values) {
    $origins[(Normalize-Key $hero.origin)] = $hero.origin
}

$heroByKey = @{}
foreach ($id in $heroes.Keys) {
    $heroByKey[(Normalize-Key $id)] = $id
}

# ---- locate source images --------------------------------------------------
if (-not (Test-Path $Source)) {
    New-Item -ItemType Directory -Force -Path $Source | Out-Null
    Write-Host "Folder input belum ada, sudah dibuat: $Source" -ForegroundColor Yellow
    Write-Host "Taruh PNG dari Canva di folder itu lalu jalankan lagi." -ForegroundColor Yellow
    exit 0
}

$files = Get-ChildItem -Path $Source -Recurse -File |
    Where-Object { $_.Extension -match '^\.(png|jpg|jpeg|webp)$' }

if ($files.Count -eq 0) {
    Write-Host "Tidak ada file PNG/JPG/WEBP di $Source" -ForegroundColor Yellow
    exit 0
}

$imported = 0
$skipped = 0
$warnings = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
    $stem = [IO.Path]::GetFileNameWithoutExtension($file.Name)
    $fileStyle = $Style

    # optional _px64 / _chibi128 suffix
    $styleMatch = [regex]::Match($stem, '[ _\-]?(px16|px32|px64|chibi128|hd256|cutin)$', 'IgnoreCase')
    if ($styleMatch.Success) {
        $fileStyle = $styleMatch.Groups[1].Value.ToLower()
        $stem = $stem.Substring(0, $stem.Length - $styleMatch.Length)
    }

    $stemKey = Normalize-Key $stem
    $targetDir = ""
    $targetName = ""

    if ($heroByKey.ContainsKey($stemKey)) {
        $heroId = $heroByKey[$stemKey]
        $targetDir = Join-Path $projectDir "assets\sprites\heroes\$heroId"
        $targetName = "$fileStyle.png"
    }
    elseif ($origins.ContainsKey($stemKey)) {
        $origin = $origins[$stemKey]
        $targetDir = Join-Path $projectDir "assets\sprites\heroes\$origin"
        $targetName = "$fileStyle.png"
    }
    else {
        # try a parent folder name (art_inbox/Naruto/hero.png)
        $relative = $file.FullName.Substring($Source.Length).TrimStart('\', '/')
        $parts = $relative -split '[\\/]'
        $dirKey = if ($parts.Count -ge 2) { Normalize-Key $parts[0] } else { "" }
        $idKey = if ($parts.Count -ge 3) { Normalize-Key $parts[1] } else { "" }

        if ($heroByKey.ContainsKey($idKey)) {
            $targetDir = Join-Path $projectDir "assets\sprites\heroes\$($heroByKey[$idKey])"
            $targetName = "$fileStyle.png"
        }
        elseif ($origins.ContainsKey($dirKey)) {
            $targetDir = Join-Path $projectDir "assets\sprites\heroes\$($origins[$dirKey])"
            $targetName = "$fileStyle.png"
        }
    }

    if ([string]::IsNullOrEmpty($targetDir)) {
        Write-Host "[SKIP] $($file.Name) - nama tidak cocok dengan hero/anime" -ForegroundColor DarkYellow
        $skipped++
        continue
    }

    $targetSize = $styleNative[$fileStyle]
    $image = $null
    $output = $null
    $graphics = $null
    try {
        $image = [System.Drawing.Image]::FromFile($file.FullName)

        if ($image.Width -lt $targetSize -or $image.Height -lt $targetSize) {
            $warnings.Add("$($file.Name) lebih kecil dari $targetSize px (hasil bisa pecah)")
        }
        if ($image.Width -ne $image.Height) {
            $warnings.Add("$($file.Name) tidak persegi ($($image.Width)x$($image.Height)) - akan diberi padding transparan")
        }

        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        $dest = Join-Path $targetDir $targetName

        if ($NoResize) {
            $image.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
            $finalSize = "$($image.Width)x$($image.Height)"
        }
        else {
            $output = New-Object System.Drawing.Bitmap($targetSize, $targetSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $graphics = [System.Drawing.Graphics]::FromImage($output)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.Clear([System.Drawing.Color]::Transparent)

            $scale = [Math]::Min($targetSize / $image.Width, $targetSize / $image.Height)
            $drawW = [int][Math]::Max(1, [Math]::Round($image.Width * $scale))
            $drawH = [int][Math]::Max(1, [Math]::Round($image.Height * $scale))
            $drawX = [int][Math]::Round(($targetSize - $drawW) / 2)
            $drawY = [int][Math]::Round(($targetSize - $drawH) / 2)
            $graphics.DrawImage($image, $drawX, $drawY, $drawW, $drawH)

            $output.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
            $finalSize = "$targetSize x $targetSize"
        }

        # transparency sanity check on the source
        $corner = $image.GetPixel(0, 0)
        if ($corner.A -eq 255) {
            $warnings.Add("$($file.Name) latar tampak tidak transparan (pojok kiri-atas opak)")
        }

        $rel = $dest.Substring($projectDir.Length).TrimStart('\')
        Write-Host "[OK] $($file.Name) -> $rel ($finalSize)" -ForegroundColor Green
        $imported++
    }
    catch {
        Write-Host "[FAIL] $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        $skipped++
    }
    finally {
        if ($graphics) { $graphics.Dispose() }
        if ($output) { $output.Dispose() }
        if ($image) { $image.Dispose() }
    }
}

# ---- status report ---------------------------------------------------------
$reportPath = Join-Path $projectDir "assets\sprites\heroes\ART_STATUS.md"
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# Status Art Karakter ($Style)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Dibuat otomatis oleh ``tools/import_canva_art.ps1``.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| Hero | Origin | Art per-hero | Fallback per-anime |")
[void]$sb.AppendLine("|---|---|---|---|")
$missing = 0
foreach ($id in $heroes.Keys) {
    $hero = $heroes[$id]
    $heroFile = Join-Path $projectDir "assets\sprites\heroes\$id\$Style.png"
    $originFile = Join-Path $projectDir "assets\sprites\heroes\$($hero.origin)\$Style.png"
    $heroMark = "-"
    if (Test-Path $heroFile) { $heroMark = "ADA" } else { $missing++ }
    $originMark = "-"
    if (Test-Path $originFile) { $originMark = "ADA" }
    [void]$sb.AppendLine("| $($hero.name) (``$id``) | $($hero.origin) | $heroMark | $originMark |")
}
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Hero belum punya art $Style : $missing / $($heroes.Count)")
Set-Content -Path $reportPath -Value $sb.ToString() -Encoding UTF8

Write-Host ""
Write-Host "Selesai: $imported diimpor, $skipped dilewati." -ForegroundColor Cyan
if ($warnings.Count -gt 0) {
    Write-Host "Peringatan:" -ForegroundColor Yellow
    foreach ($w in $warnings) { Write-Host "  - $w" -ForegroundColor Yellow }
}
Write-Host "Status: assets\sprites\heroes\ART_STATUS.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Langkah berikutnya:" -ForegroundColor Cyan
Write-Host "  godot --headless --path `"$projectDir`" --import"
Write-Host "  powershell -ExecutionPolicy Bypass -File tools\build_android.ps1"
