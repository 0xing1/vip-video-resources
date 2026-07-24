@echo off
chcp 65001 >nul
setlocal

:: ── N_m3u8DL-RE 便捷启动 ──
:: ── 用法: n_m3u8dl.cmd <视频链接> [选项] ──
:: ── 示例: n_m3u8dl.cmd "https://v.qq.com/x/cover/xxx.html" --auto-select ──

set "PROJECT_DIR=%~dp0"
set "EXE=%PROJECT_DIR%tools\N_m3u8DL-RE\N_m3u8DL-RE.exe"
set "SAVE_DIR=%PROJECT_DIR%downloads"
set "TMP_DIR=%PROJECT_DIR%cache\n_m3u8dl"

if not exist "%EXE%" (
    echo ⚠️  N_m3u8DL-RE 未找到，请先下载到 tools\N_m3u8DL-RE\
    exit /b 1
)

if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"

echo 📁 下载目录: %SAVE_DIR%
echo 📁 临时目录: %TMP_DIR%
echo.

"%EXE%" --save-dir "%SAVE_DIR%" --tmp-dir "%TMP_DIR%" %*

endlocal
