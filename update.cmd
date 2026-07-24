@echo off
chcp 65001 >nul
setlocal

:: ── 自动更新脚本 ──
:: 委托给 scripts/update.py，跨平台、无外部依赖
:: 本地使用：双击运行或将参数传给 update.py
:: CI 使用：python scripts/update.py

set "CONFIG=%~dp0config.json"

:: ── 加载 config.json ──
if not exist "%CONFIG%" (
    echo ❌ config.json 不存在！请先运行 setup.cmd 配置环境
    pause
    exit /b 1
)
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-Content '%CONFIG%' -Raw | ConvertFrom-Json).python" 2^>nul') do set "PYTHON=%%a"

if "%PYTHON%"=="" set "PYTHON=python"

cd /d "%~dp0"
"%PYTHON%" scripts\update.py %*

endlocal
