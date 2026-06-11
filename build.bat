@echo off
REM OwlContext Backend Build Script for Windows
REM 编译后端 Python 应用为独立可执行文件

setlocal enabledelayedexpansion

echo ========================================
echo OwlContext 后端编译脚本（Windows）
echo ========================================
echo.

REM 1. 检查 Python
echo [1/6] 检查 Python...
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Python，请先安装 Python 3.10 或更高版本
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)

python --version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo Python 版本: %PYTHON_VERSION%
echo.

REM 2. 检查是否使用 uv
echo [2/6] 检查依赖管理工具...
set USE_UV=false
where uv >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] 找到 uv，将使用 uv 管理依赖
    set USE_UV=true
) else (
    echo [!] 未找到 uv，将使用 pip 管理依赖
    echo    （推荐安装 uv 以获得更快的依赖安装速度）
)
echo.

REM 3. 安装项目依赖
echo [3/6] 安装项目依赖...
if "%USE_UV%"=="true" (
    echo 执行: uv sync
    uv sync
    if %errorlevel% neq 0 (
        echo [错误] uv sync 失败
        pause
        exit /b 1
    )
) else (
    echo 执行: pip install -e .
    python -m pip install -e .
    if %errorlevel% neq 0 (
        echo [错误] pip install 失败
        pause
        exit /b 1
    )
)
echo [✓] 依赖安装完成
echo.

REM 4. 安装 PyInstaller
echo [4/6] 检查并安装 PyInstaller...
if "%USE_UV%"=="true" (
    uv run python -c "import PyInstaller" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [!] PyInstaller 未安装，正在安装...
        uv pip install pyinstaller
        if %errorlevel% neq 0 (
            echo [错误] PyInstaller 安装失败
            pause
            exit /b 1
        )
    ) else (
        echo [✓] PyInstaller 已安装
    )
) else (
    python -c "import PyInstaller" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [!] PyInstaller 未安装，正在安装...
        python -m pip install pyinstaller
        if %errorlevel% neq 0 (
            echo [错误] PyInstaller 安装失败
            pause
            exit /b 1
        )
    ) else (
        echo [✓] PyInstaller 已安装
    )
)
echo.

REM 5. 清理之前的构建
echo [5/6] 清理之前的构建目录...
if exist "dist" (
    echo 删除 dist 目录...
    rmdir /s /q dist
)
if exist "build" (
    echo 删除 build 目录...
    rmdir /s /q build
)
echo [✓] 清理完成
echo.

REM 6. 使用 PyInstaller 构建
echo [6/6] 使用 PyInstaller 构建应用...
echo 这可能需要几分钟时间，请耐心等待...
echo.

if "%USE_UV%"=="true" (
    echo 执行: uv run pyinstaller --clean --noconfirm --log-level INFO opencontext.spec
    uv run pyinstaller --clean --noconfirm --log-level INFO opencontext.spec
) else (
    echo 执行: pyinstaller --clean --noconfirm --log-level INFO opencontext.spec
    pyinstaller --clean --noconfirm --log-level INFO opencontext.spec
)

if %errorlevel% neq 0 (
    echo.
    echo [错误] PyInstaller 构建失败
    echo 请检查上面的错误信息
    pause
    exit /b 1
)

echo.
echo ========================================
echo 验证构建结果...
echo ========================================

REM 检查可执行文件
if exist "dist\main.exe" (
    echo [✓] 构建成功！
    echo.
    
    REM 复制配置文件
    if exist "config" (
        echo 复制配置文件到 dist 目录...
        xcopy /E /I /Y config dist\config >nul
        echo [✓] 配置文件已复制
    ) else (
        echo [!] 警告: 未找到 config 目录
    )
    
    echo.
    echo ========================================
    echo 构建完成！
    echo ========================================
    echo.
    echo 可执行文件位置: dist\main.exe
    echo.
    echo 运行方式:
    echo   cd dist
    echo   main.exe start
    echo.
    echo 可选参数:
    echo   --port 9000           指定端口
    echo   --host 0.0.0.0        指定主机地址
    echo   --config config\config.yaml  指定配置文件
    echo.
    
    REM 显示输出目录内容
    echo dist 目录内容:
    dir /B dist
    echo.
    
) else (
    echo [错误] 构建失败，未找到 dist\main.exe
    echo 请检查上面的 PyInstaller 日志以获取详细错误信息
    pause
    exit /b 1
)

echo ========================================
echo 构建成功完成！
echo ========================================
pause
