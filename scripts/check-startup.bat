@echo off
chcp 65001 >nul
echo ========================================
echo 检查 OwlContext 开机启动配置
echo ========================================
echo.

echo 正在检查注册表项...
echo.

setlocal enabledelayedexpansion

reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "OwlContext" >nul 2>&1
if %errorlevel% == 0 (
    echo [✓] 找到注册表项: OwlContext
    echo.
    echo 注册表值:
    reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "OwlContext"
    echo.
    echo 验证路径是否正确:
    for /f "tokens=3*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "OwlContext" ^| findstr /i "OwlContext"') do (
        set "REG_VALUE=%%b"
        echo 注册表中的完整命令: %%b
        echo.
        
        rem 提取可执行文件路径（移除引号和参数）
        set "CHECK_PATH=%%b"
        rem 移除引号
        set "CHECK_PATH=!CHECK_PATH:"=!"
        rem 移除 --hidden 参数
        set "CHECK_PATH=!CHECK_PATH: --hidden=!"
        set "CHECK_PATH=!CHECK_PATH: --startup=!"
        
        if exist "!CHECK_PATH!" (
            echo [✓] 可执行文件存在: !CHECK_PATH!
            
            rem 检查是否包含后台启动参数
            echo %%b | findstr /i "\-\-hidden" >nul
            if !errorlevel! == 0 (
                echo [✓] 包含后台启动参数 --hidden
                echo     开机后将直接在后台托盘运行，不显示窗口
            ) else (
                echo [!] 未包含后台启动参数
                echo     开机后将显示主窗口
            )
        ) else (
            echo [✗] 可执行文件不存在: !CHECK_PATH!
            echo     请检查路径是否正确
        )
    )
) else (
    echo [✗] 未找到注册表项: OwlContext
    echo.
    echo 这意味着开机启动功能可能未正确配置。
    echo 请重新运行安装程序，或手动在应用程序设置中启用开机启动。
)

endlocal

echo.
echo ========================================
echo 检查完成
echo ========================================
pause

