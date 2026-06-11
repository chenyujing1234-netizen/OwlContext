@echo off
REM 快速构建 - 跳过 TypeCheck

echo ========================================
echo 快速构建前端（跳过 TypeCheck）
echo ========================================
echo.

cd /d %~dp0

echo [1/6] Copy backend...
call npm run copy-backend
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo [2/6] Build externals...
call npm run build:externals
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo [3/6] Build Python...
node build-python.js
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo [4/6] Clean dist...
node -e "if(process.platform==='win32'){require('fs').rmSync('./dist',{recursive:true,force:true})}"

echo.
echo [5/6] Build with electron-vite...
call npx electron-vite build
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo [6/6] Package with electron-builder...
call npx electron-builder --win
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo ========================================
echo 构建完成！
echo ========================================

