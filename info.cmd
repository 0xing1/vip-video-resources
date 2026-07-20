@echo off
chcp 65001 >nul

:: ── 查看视频所有可用画质 ──
:: ── 用法: info.cmd <视频链接> ──

if "%~1"=="" (
    echo ⚠️  用法: info.cmd ^<视频链接^>
    echo 示例: info.cmd "https://v.qq.com/x/cover/xxx.html"
    exit /b 1
)

set "PYTHON=D:\Python\Python313\python.exe"
set "YOU_GET=D:\Python\Python313\Scripts\you-get.exe"

echo 🔍 查询可用画质...
echo.
"%PYTHON%" "%YOU_GET%" --info "%~1"
