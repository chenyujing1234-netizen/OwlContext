@echo off
REM OwlContext Inno Setup 安装程序构建脚本

setlocal enabledelayedexpansion

echo ============================================================
echo OwlContext 安装程序构建脚本
echo ============================================================
echo.

REM 1. 检查Inno Setup是否安装
set "INNO_PATH=E:\Program Files (x86)\Inno Setup 6"
set "INNO_SETUP=%INNO_PATH%\ISCC.exe"
set "INNO_COMPIL32=%INNO_PATH%\Compil32.exe"

echo [✓] 检查 Inno Setup 6...
echo.

REM 2. 检查是否已经构建了应用程序
if not exist "frontend\dist\win-unpacked\OwlContext.exe" (
    echo [警告] 未找到已构建的应用程序
    echo 请先运行前端的构建流程:
    echo   cd frontend
    echo   npm run build:win
    echo.
    echo 预期路径: frontend\dist\win-unpacked\OwlContext.exe
    echo.
    pause
    exit /b 1
)

echo [✓] 找到已构建的应用程序: frontend\dist\win-unpacked\OwlContext.exe
echo.

REM 3. 清理之前的安装程序输出
echo [Clean] Checking for old installation packages...
if exist "build-output\OwlContext-Setup-*.exe" (
    echo Removing old installation packages...
    for %%F in (build-output\OwlContext-Setup-*.exe) do (
        taskkill /F /IM "%%~nxF" 2>nul
        timeout /t 1 /nobreak >nul 2>&1
        del /F /Q "%%F" 2>nul
    )
    echo Clean up completed.
    echo.
)

REM 4. 检查Inno Setup脚本是否存在
if not exist "install-setup.iss" (
    echo [错误] 找不到 install-setup.iss 文件
    echo.
    pause
    exit /b 1
)

REM 5. 编译Inno Setup安装程序
echo ============================================================
echo 开始编译安装程序...
echo ============================================================
echo.

REM 编译安装程序 - 首先尝试使用 ISCC.exe
echo 尝试使用 ISCC.exe 编译...
"%INNO_SETUP%" install-setup.iss
set COMPILE_SUCCESS=%ERRORLEVEL%

REM 如果 ISCC.exe 失败，尝试使用 Compil32.exe
if %COMPILE_SUCCESS% NEQ 0 (
    echo ISCC.exe 失败，尝试使用 Compil32.exe...
    "%INNO_COMPIL32%" /cc install-setup.iss
    set COMPILE_SUCCESS=%ERRORLEVEL%
)

if %COMPILE_SUCCESS% NEQ 0 (
    echo.
    echo ============================================================
    echo [错误] 安装程序编译失败
    echo ============================================================
    echo.
    echo 请检查以下内容:
    echo   1. Inno Setup 是否正确安装
    echo   2. install-setup.iss 语法是否正确
    echo   3. frontend\dist\win-unpacked\ 目录是否存在
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo 构建完成！
echo ============================================================
echo.
echo 安装程序输出位置: build-output\OwlContext-Setup-0.1.5-beta.exe
echo.

REM 6. 列出构建的文件
if exist "build-output\OwlContext-Setup-*.exe" (
    echo [OK] Installation package successfully created:
    for %%F in (build-output\OwlContext-Setup-*.exe) do (
        echo    %%F
        echo    Size: 
        for %%A in ("%%F") do echo %%~zA bytes
    )
    echo.
    echo Next steps:
    echo   1. Test the installer
    echo   2. Distribute to users
    echo   3. Upload to distribution platform
) else (
    echo [WARNING] Installation package not found
    echo Please check Inno Setup compilation log
)

echo.
pause

endlocal

