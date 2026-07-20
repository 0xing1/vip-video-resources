@echo off
chcp 65001 >nul
setlocal

:: ── 路径配置 ──
set "PROJECT_DIR=%~dp0"
set "PYTHON=D:\Python\Python313\python.exe"
set "YOU_GET=D:\Python\Python313\Scripts\you-get.exe"

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
