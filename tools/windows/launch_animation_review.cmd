@echo off
setlocal
set "MODE=install"
if /I "%~1"=="preview" set "MODE=preview"
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0launch_animation_review.ps1" -Mode "%MODE%"
if errorlevel 1 (
    echo.
    echo Nothing was deleted or reset. Read the message above.
    pause
    exit /b 1
)
exit /b 0
