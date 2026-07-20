@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ── 边播边看：解析后直接流媒体播放，不下载文件 ──
:: ── 用法: stream.cmd <视频链接> [线路号1-9] ──
:: ── 示例: stream.cmd "https://v.qq.com/x/cover/xxx.html" ──
:: ── 示例: stream.cmd "https://v.qq.com/x/cover/xxx.html" 3 ──

if "%~1"=="" (
    echo ⚠️  用法: stream.cmd ^<视频链接^> [线路号]
    echo.
    echo 示例:
    echo   stream.cmd "https://v.qq.com/x/cover/xxx.html"
    echo   stream.cmd "https://v.qq.com/x/cover/xxx.html" 3
    echo.
    echo 线路: 1=m3u8.tv  2=ppflv  3=盘古  4=parwix  5=playerjy  6=aidouer  7=nnxv  8=xmflv  9=yangtu
    echo 默认线路1，播不了换一条。
    exit /b 1
)

set "POTPLAYER=D:\DAUM\PotPlayer\PotPlayerMini64.exe"

:: ── API 线路表 ──
set "API1=https://jx.m3u8.tv/jiexi/?url="
set "API2=https://jx.ppflv.com/?url="
set "API3=https://json.pangujiexi.com:12345/json.php?url="
set "API4=https://api.parwix.com:4433/analysis/json/?url="
set "API5=https://jx.playerjy.com/?url="
set "API6=https://jx.aidouer.net/?url="
set "API7=https://jx.nnxv.cn/tv.php?url="
set "API8=https://jx.xmflv.com/?url="
set "API9=https://jx.yangtu.tv/?url="

set "LINE=%~2"
if "%LINE%"=="" set "LINE=1"
set "API=!API%LINE%!"

if "%API%"=="" (
    echo ❌ 无效线路号: %LINE% (1-9)
    exit /b 1
)

set "VIDEO_URL=%~1"
set "PARSE_URL=!API!!VIDEO_URL!"

echo 🎬 正在启动 PotPlayer...
echo 🔗 解析线路: %LINE%
echo 📺 流媒体播放，不保存文件
echo.
echo 💡 如果播放失败，换条线路: stream.cmd "链接" 2

start "" "%POTPLAYER%" "%PARSE_URL%"

endlocal
