@echo off
REM Clean build directories to fix electron-builder errors

echo Cleaning build directories...

REM Kill any running OwlContext processes
echo Checking for running OwlContext processes...
taskkill /F /IM OwlContext.exe 2>nul
if %errorlevel% equ 0 (
    echo Killed running OwlContext process
    timeout /t 2 /nobreak >nul
) else (
    echo No running OwlContext process found
)

REM Also check for electron processes
taskkill /F /IM electron.exe 2>nul
if %errorlevel% equ 0 (
    echo Killed running electron process
    timeout /t 1 /nobreak >nul
)

REM Force unlock files before removing (requires admin for takeown/icacls)
echo Attempting to unlock files...
cd frontend
if exist "dist\win-unpacked\OwlContext.exe" (
    attrib -R "dist\win-unpacked\OwlContext.exe" 2>nul
    takeown /F "dist\win-unpacked\OwlContext.exe" 2>nul
    icacls "dist\win-unpacked\OwlContext.exe" /grant %USERNAME%:F 2>nul
)
cd ..

REM Remove dist directory
if exist "frontend\dist" (
    echo Removing frontend\dist directory...
    timeout /t 2 /nobreak >nul
    rmdir /s /q "frontend\dist" 2>nul
    if %errorlevel% equ 0 (
        echo Done.
    ) else (
        echo Warning: Could not remove. Try running as administrator or close file explorer.
    )
) else (
    echo frontend\dist directory does not exist
)

REM Remove out directory
if exist "frontend\out" (
    echo Removing frontend\out directory...
    rmdir /s /q "frontend\out" 2>nul
    echo Done.
) else (
    echo frontend\out directory does not exist
)

echo.
echo Build directories cleaned. You can now run: cd frontend ^&^& npm run build:win
echo.
pause

