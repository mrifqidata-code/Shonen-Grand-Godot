# tools/build_android.ps1
# Build APK for Shonen Grand with the "Android" export preset.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools\build_android.ps1
#   powershell -ExecutionPolicy Bypass -File tools\build_android.ps1 -Mode debug
param(
    [ValidateSet("release", "debug")]
    [string]$Mode = "release",
    [string]$Godot = "C:\Users\PAB-ACDM-NB2159\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
)

$ErrorActionPreference = "Stop"
$projectDir = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $projectDir "builds"
$apkPath = Join-Path $outDir "shonen_grand_$Mode.apk"

if (-not (Test-Path $Godot)) {
    throw "Godot executable not found: $Godot"
}

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# Avoid a stale APK surviving a failed/partial export.
Remove-Item $apkPath -Force -ErrorAction SilentlyContinue

$exportFlag = if ($Mode -eq "release") { "--export-release" } else { "--export-debug" }
$apkName = "shonen_grand_$Mode.apk"

$exportProc = Start-Process -FilePath $Godot -ArgumentList @("--headless", "--verbose", $exportFlag, "Android", "builds\$apkName") -WorkingDirectory $projectDir -Wait -PassThru
$exportProc.WaitForExit()
$exitCode = $exportProc.ExitCode
Write-Host "Godot exit code: $exitCode" -ForegroundColor DarkGray

$log = Get-Content "$env:TEMP\godot_export.log" -ErrorAction SilentlyContinue
if (-not (Test-Path $apkPath)) {
    Write-Host "BUILD FAILED - no APK produced" -ForegroundColor Red
    if ($log) { $log | Select-Object -Last 30 }
    exit 1
}

$sizeMb = [math]::Round((Get-Item $apkPath).Length / 1MB, 1)
Write-Host "OK: $apkPath ($sizeMb MB)" -ForegroundColor Green

$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
if (Test-Path $adb) {
    try {
        $devices = (& $adb devices 2>$null) | Select-String "device$"
        if ($devices) {
            Write-Host "Device detected. Install with:" -ForegroundColor Yellow
            Write-Host "  `"$adb`" install -r `"$apkPath`""
        }
    }
    catch {
        # adb is optional; never fail the build because of it.
    }
}

exit 0
