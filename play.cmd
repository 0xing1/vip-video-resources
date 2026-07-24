@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ── 用法: play.cmd <视频链接> [画质] ──
:: ── 示例: play.cmd "https://v.qq.com/x/cover/xxx.html" 1080P ──

if "%~1"=="" (
    echo ⚠️  用法: play.cmd ^<视频链接^> [画质]
    echo.
    echo 示例:
    echo   play.cmd "https://v.qq.com/x/cover/xxx.html"
    echo   play.cmd "https://v.qq.com/x/cover/xxx.html" 1080P
    echo.
    echo 先查看有哪些画质可选:
    echo   info.cmd "https://v.qq.com/x/cover/xxx.html"
    exit /b 1
)

set "CONFIG=%~dp0config.json"
set "PROJECT_DIR=%~dp0"

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

set "OUTPUT_DIR=%PROJECT_DIR%downloads"
set "CACHE_DIR=%PROJECT_DIR%cache\you-get"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"

if "%~2"=="" (
    echo 🎬 自动选择最高画质下载...
    "%PYTHON%" "%YOU_GET%" --output-dir "%OUTPUT_DIR%" --cache-dir "%CACHE_DIR%" "%~1"
) else (
    echo 🎬 下载画质: %~2 ...
    "%PYTHON%" "%YOU_GET%" --output-dir "%OUTPUT_DIR%" --cache-dir "%CACHE_DIR%" --format="%~2" "%~1"
)

endlocal
