@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ── 自动更新脚本 ──
:: ── 1. 更新 Python 工具 (you-get, yt-dlp) ──
:: ── 2. 从 GitHub 上游项目拉取最新 API 线路 ──
:: ── 3. 重新生成 api-lines.js ──
:: ── 4. 健康检查所有线路 ──
:: ── 5. 有更新则自动提交到 GitHub ──

set "PROJECT_DIR=%~dp0"
set "PYTHON=D:\Python\Python313\python.exe"
set "PIP=D:\Python\Python313\python.exe -m pip"
set "LOG=%PROJECT_DIR%cache\update.log"
set "CHANGED=0"

if not exist "%PROJECT_DIR%cache" mkdir "%PROJECT_DIR%cache"

echo ========================================
echo  VIP 视频解析工具 — 自动更新
echo  %date% %time%
echo ========================================
echo.

:: ── Step 1: 更新 Python 工具 ──
echo [1/4] 更新 Python 工具...
echo [1/4] 更新 Python 工具... >> "%LOG%"
"%PYTHON%" -m pip install --upgrade you-get yt-dlp --quiet 2>&1 >> "%LOG%"
if %errorlevel% equ 0 (
    echo    ✓ you-get / yt-dlp 已是最新
) else (
    echo    ⚠ pip 更新有警告，查看 %LOG%
)

:: ── Step 2: 从上游拉取 API 线路 ──
echo.
echo [2/4] 从上游项目拉取 API 线路...

:: 上游源（可添加多个）
set "UPSTREAM_RAW=https://raw.githubusercontent.com/Awle007/xshyunvip-video-player/main/index.html"
set "TEMP_HTML=%PROJECT_DIR%cache\upstream.html"

curl -s --max-time 15 -o "%TEMP_HTML%" "%UPSTREAM_RAW%" 2>nul

if exist "%TEMP_HTML%" (
    :: PowerShell 提取 API URL
    for /f "delims=" %%a in ('powershell -NoProfile -Command ^
      "$html = Get-Content '%TEMP_HTML%' -Raw; $pattern = 'https?://[^""\''\s<>]+'; $matches = [regex]::Matches($html, $pattern); $urls = $matches.Value | Where-Object { $_ -match '(jiexi|parse|analysis|json|m3u8)' } | Select-Object -Unique; Write-Output $urls.Count" 2^>nul') do set "NEW_COUNT=%%a"

    echo    从上游发现 %NEW_COUNT% 条潜在线路
    del "%TEMP_HTML%"
) else (
    echo    ⚠ 无法连接上游，使用本地配置
)

:: ── Step 3: 重新生成 api-lines.js ──
echo.
echo [3/4] 重新生成 api-lines.js...

set "JSON=%PROJECT_DIR%api-lines.json"
set "JS=%PROJECT_DIR%api-lines.js"

if exist "%JSON%" (
    powershell -NoProfile -Command ^
      "$json = Get-Content '%JSON%' -Raw | ConvertFrom-Json; "^
      "$lines = ($json.lines | ForEach-Object { '  {\"id\": ' + $_.id + ', \"name\": \"' + $_.name + '\", \"url\": \"' + $_.url + '\"}' }) -join ',' + \"`n\"; "^
      "$newJs = '// auto-generated ' + (Get-Date -Format 'yyyy-MM-dd HH:mm') + \"`n\" + '// edit api-lines.json, then run update.cmd' + \"`n\" + 'window.__API_LINES__ = [' + \"`n\" + $lines + '];' + \"`n\"; "^
      "$oldJs = if (Test-Path '%JS%') { Get-Content '%JS%' -Raw } else { '' }; "^
      "if ($newJs -ne $oldJs) { [IO.File]::WriteAllText('%JS%', $newJs); Write-Output 'CHANGED' } else { Write-Output 'UNCHANGED' }" 2>nul > "%PROJECT_DIR%cache\gen_result.txt"

    set /p GEN_RESULT=<"%PROJECT_DIR%cache\gen_result.txt"
    if "!GEN_RESULT!"=="CHANGED" (
        echo    ✓ api-lines.js 已更新
        set "CHANGED=1"
    ) else (
        echo    ✓ api-lines.js 无需更新
    )
) else (
    echo    ⚠ api-lines.json 不存在，跳过
)

:: ── Step 4: 健康检查 ──
echo.
echo [4/4] 线路健康检查...
set "ALIVE=0"
set "DEAD=0"

powershell -NoProfile -Command ^
  "$json = Get-Content '%JSON%' -Raw | ConvertFrom-Json; "^
  "foreach ($line in $json.lines) { "^
  "  try { $r = Invoke-WebRequest -Uri ($line.url + 'https://v.qq.com') -TimeoutSec 10 -UseBasicParsing; Write-Host ('    ✓ 线路' + $line.id + ' ' + $line.name + ' OK') } "^
  "  catch { Write-Host ('    ✗ 线路' + $line.id + ' ' + $line.name + ' 超时/不可用') } "^
  "}" 2>nul

echo.
echo ========================================
echo  完成: %date% %time%
echo ========================================

:: ── Step 5: 有更新则提交推送 ──
if "%CHANGED%"=="1" (
    cd /d "%PROJECT_DIR%"
    git add api-lines.js api-lines.json
    git commit -m "🔄 自动更新 API 线路 [%date%]" 2>nul
    git push 2>nul
    if %errorlevel% equ 0 (
        echo  ✓ 已推送到 GitHub
    ) else (
        echo  ⚠ 推送失败，请手动 git push
    )
)

echo.
endlocal
