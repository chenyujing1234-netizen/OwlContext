@echo off
REM Fix electron-builder file locking issues (ASAR integrity check, rcedit, etc.)

echo ========================================
echo Fixing electron-builder file locking issues...
echo ========================================
echo.

REM Step 1: Kill all related processes
echo [1/5] Killing all OwlContext and electron processes...
taskkill /F /IM OwlContext.exe 2>nul
if %errorlevel% equ 0 (
    echo   - Killed OwlContext.exe
) else (
    echo   - No OwlContext.exe running
)
taskkill /F /IM electron.exe 2>nul
if %errorlevel% equ 0 (
    echo   - Killed electron.exe
) else (
    echo   - No electron.exe running
)
timeout /t 3 /nobreak >nul
echo Done.

REM Step 2: Force unlock any locked files in dist directory
echo [2/5] Unlocking files in dist directory...
cd frontend
if exist "dist\win-unpacked\OwlContext.exe" (
    echo   - Removing read-only attribute from OwlContext.exe...
    attrib -R "dist\win-unpacked\OwlContext.exe" 2>nul
    echo   - Attempting to take ownership (may require recover admin rights)...
    takeown /F "dist\win-unpacked\OwlContext.exe" relations 2>nul
    icacls "dist\win-unpacked\OwlContext.exe" /grant %USERNAME%:F 2>nul
)
cd ..
echo Done.

REM Step 3: Wait for file handles to release
echo [3/5] Waiting for file handles to release...
timeout /t 2 /nobreak >nul
echo Done.

REM Step 4: Remove dist directory
echo [4/5] Removing dist directory...
if exist "frontend\dist" (
    echo   - Attempting to remove dist directory...
    rmdir /s /q "frontend\dist" 2>nul
    if %errorlevel% equ 0 (
        echo   - Successfully removed
    ) else (
        echo   - Warning: Could not remove, may need manual deletion
        echo   - Try closing file explorer and running as administrator
    )
) else (
    echo   - Directory does not exist
)
echo Done.

REM Step 5: Remove out directory  
echo [5/5] Removing out directory...
if exist "frontend\out" (
    rmdir /s /q "frontend\out" 2>nul
    echo   - Removed
) else (
    echo   - Directory does not exist
)
echo Done.

echo.
echo ========================================
echo Cleanup complete!
echo ========================================
echo.
echo Now you can run:
echo   cd frontend
echo   npm run build:win
echo.
echo If the error still persists:
echo   1. Close file explorer if it's open in the dist folder
echo   2. Disable antivirus temporarily  
echo   3. Run this script and build command as Administrator
echo   4. Check if any backup software is locking files
echo.
pause
