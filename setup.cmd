@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ── 首次使用引导脚本 ──
:: 生成 config.json，配置本地工具路径

echo.
echo  ╔══════════════════════════════════════════╗
echo  ║   VIP 视频解析工具 — 首次配置向导       ║
echo  ╚══════════════════════════════════════════╝
echo.

set "CONFIG=%~dp0config.json"

:: ── Python 路径 ──
echo [1/3] Python 路径（用于 you-get / yt-dlp 下载）
echo.
echo 例如: D:\Python\Python313\python.exe
echo 提示：如果已安装 Python 且在 PATH 中，直接填 python
echo.
set /p PYTHON_PATH="Python 路径: "
if "%PYTHON_PATH%"=="" (
    echo 未输入，使用默认: python
    set "PYTHON_PATH=python"
)

:: ── PotPlayer 路径 ──
echo.
echo [2/3] PotPlayer 路径（用于流媒体播放）
echo.
echo 例如: D:\DAUM\PotPlayer\PotPlayerMini64.exe
echo 提示：如果不需要流媒体播放功能，可以跳过
echo.
set /p POTPLAYER_PATH="PotPlayer 路径（可选，回车跳过）: "

:: ── 项目路径 ──
set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

echo.
echo [3/3] 项目路径（自动检测）
echo   %PROJECT_DIR%
echo   确认无误？按 Enter 继续，或输入新路径修改
echo.
set /p OVERRIDE_DIR="项目路径（回车确认）: "
if not "%OVERRIDE_DIR%"=="" set "PROJECT_DIR=%OVERRIDE_DIR%"

:: ── 生成 config.json ──
echo { > "%CONFIG%"
echo   "python": "%PYTHON_PATH:\=\\%" >> "%CONFIG%"
if not "%POTPLAYER_PATH%"=="" (
    echo   ,"potplayer": "%POTPLAYER_PATH:\=\\%" >> "%CONFIG%"
) else (
    echo   ,"potplayer": "" >> "%CONFIG%"
)
echo   ,"project_dir": "%PROJECT_DIR:\=\\%" >> "%CONFIG%"
echo } >> "%CONFIG%"

echo.
echo  ╔══════════════════════════════════════════╗
echo  ║   ✓ 配置完成！                           ║
echo  ╚══════════════════════════════════════════╝
echo.
echo  config.json 已生成在项目根目录。
echo  现在可以使用:
echo    stream.cmd   — 边播边看
echo    play.cmd     — 下载最高画质
echo    info.cmd     — 查看可用画质
echo    you-get.cmd  — you-get 完整功能
echo.
echo  如果工具路径变更，重新运行 setup.cmd 或直接编辑 config.json
echo.
pause

endlocal
