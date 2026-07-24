@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ── 查看视频所有可用画质 ──
:: ── 用法: info.cmd <视频链接> ──

if "%~1"=="" (
    echo ⚠️  用法: info.cmd ^<视频链接^>
    echo 示例: info.cmd "https://v.qq.com/x/cover/xxx.html"
    exit /b 1
)

set "CONFIG=%~dp0config.json"

:: ── 加载 config.json ──
if not exist "%CONFIG%" (
    echo ❌ config.json 不存在！请先运行 setup.cmd 配置环境
    pause
    exit /b 1
)
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-Content '%CONFIG%' -Raw | ConvertFrom-Json).python" 2^>nul') do set "PYTHON=%%a"

if "%PYTHON%"=="" set "PYTHON=python"

set "YOU_GET=%PYTHON%\..\Scripts\you-get.exe"
for %%i in ("%YOU_GET%") do set "YOU_GET=%%~fi"

echo 🔍 查询可用画质...
echo.
"%PYTHON%" "%YOU_GET%" --info "%~1"

endlocal
