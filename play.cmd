@echo off
chcp 65001 >nul
setlocal

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

set "PROJECT_DIR=%~dp0"
set "PYTHON=D:\Python\Python313\python.exe"
set "YOU_GET=D:\Python\Python313\Scripts\you-get.exe"
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
