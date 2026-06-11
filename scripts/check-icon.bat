@echo off
REM Check if icon.ico exists, if not, provide instructions

echo Checking icon files...

if exist "frontend\build\icon.png" (
    echo [OK] icon.png exists
) else (
    echo [ERROR] icon.png not found in frontend\build\
    echo Please copy logo_new.png to frontend\build\icon.png
    exit /b 1
)

if exist "frontend\build\icon.ico" (
    echo [OK] icon.ico exists
    echo.
    echo All icon files are ready!
) else (
    echo [WARNING] icon.ico not found in frontend\build\
    echo.
    echo To generate icon.ico, you have two options:
    echo.
    echo Option 1: Build the app first (recommended)
    echo   cd frontend
    echo   npm run build:win
    echo   electron-builder will automatically generate icon.ico
    echo.
    echo Option 2: Use an online converter
    echo   1. Visit https://convertio.co/png-ico/ or https://redketchup.io/icon-converter
    echo   2. Upload frontend\build\icon.png
    echo   3. Download the generated icon.ico
    echo   4. Save it to frontend\build\icon.ico
    echo.
    exit /b 1
)

pause

