@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ── you-get 便捷启动 ──

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

:: ── 固定输出目录到项目文件夹 ──
set "OUTPUT_DIR=%PROJECT_DIR%downloads"
set "CACHE_DIR=%PROJECT_DIR%cache\you-get"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"

echo 📁 下载目录: %OUTPUT_DIR%
echo 📁 缓存目录: %CACHE_DIR%
echo.

:: ── 执行 you-get，注入路径参数 ──
"%PYTHON%" "%YOU_GET%" --output-dir "%OUTPUT_DIR%" --cache-dir "%CACHE_DIR%" %*

endlocal
