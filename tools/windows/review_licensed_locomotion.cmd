@echo off
setlocal
set "FW_REVIEW_PATH=C:\Projects\FALSE-WORLD-animation-review"
if exist "%FW_REVIEW_PATH%" (
    echo Review folder already exists. It has been preserved: %FW_REVIEW_PATH%
    echo Nothing was overwritten. Choose a different unused review path manually.
    goto failed
)
if not exist "C:\Projects\" (
    echo C:\Projects does not exist. Stop and choose your projects folder manually.
    goto failed
)
git clone --branch feat/authentic-directional-locomotion --single-branch https://github.com/reydereditor-del/FALSE-WORLD.git "%FW_REVIEW_PATH%"
if errorlevel 1 goto failed
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0install_licensed_locomotion.ps1" -ProjectRoot "%FW_REVIEW_PATH%"
if errorlevel 1 goto failed
exit /b 0
:failed
echo Review setup stopped. Your original FALSE-WORLD checkout was not changed.
pause
exit /b 1
