@echo off
rem Double-click to build + deliver the APK. Art in art_inbox/ is imported first.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\ship.ps1"
if errorlevel 1 (
  echo.
  echo Build gagal. Lihat pesan di atas.
)
pause
