@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ── 边播边看：流媒体播放，不下载 ──
:: ── API 线路从 api-lines.json 读取，update.cmd 自动更新 ──
:: ── 用法: stream.cmd <视频链接> [线路号] ──

if "%~1"=="" (
    echo ⚠️  用法: stream.cmd ^<视频链接^> [线路号]
    echo.
    echo 示例:
    echo   stream.cmd "https://v.qq.com/x/cover/xxx.html"
    echo   stream.cmd "https://v.qq.com/x/cover/xxx.html" 3
    echo.
    echo 线路号为空时默认使用线路1，播不了换其他线路。
    echo 可用线路见 api-lines.json
    exit /b 1
)

set "CONFIG=%~dp0config.json"
set "JSON_CONFIG=%~dp0api-lines.json"

:: ── 加载 config.json ──
if not exist "%CONFIG%" (
    echo ❌ config.json 不存在！请先运行 setup.cmd 配置环境
    pause
    exit /b 1
)
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Get-Content '%CONFIG%' -Raw | ConvertFrom-Json).potplayer" 2^>nul') do set "POTPLAYER=%%a"

if "%POTPLAYER%"=="" (
    echo ❌ config.json 中未配置 PotPlayer 路径
    echo 请编辑 config.json 或运行 setup.cmd 重新配置
    exit /b 1
)

if not exist "%JSON_CONFIG%" (
    echo ❌ 配置文件 api-lines.json 不存在！
    exit /b 1
)

set "LINE=%~2"
if "%LINE%"=="" set "LINE=1"

:: ── 用 PowerShell 从 JSON 提取指定线路的 URL ──
for /f "delims=" %%a in ('powershell -NoProfile -Command ^
  "$json = Get-Content '%JSON_CONFIG%' -Raw | ConvertFrom-Json; $line = $json.lines | Where-Object { $_.id -eq %LINE% }; if ($line) { Write-Output $line.url } else { Write-Output '' }" 2^>nul') do set "API_URL=%%a"

if "%API_URL%"=="" (
    echo ❌ 无效线路号: %LINE%
    echo 请查看 api-lines.json 获取可用线路
    exit /b 1
)

set "PARSE_URL=%API_URL%%~1"

echo 🎬 正在启动 PotPlayer...
echo 🔗 线路 %LINE%: %API_URL%
echo 📺 流媒体播放，不保存文件
echo.
echo 💡 如果播放失败，换条线路: stream.cmd "链接" 线路号

start "" "%POTPLAYER%" "%PARSE_URL%"

endlocal
