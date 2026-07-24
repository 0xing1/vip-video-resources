#!/usr/bin/env python3
"""
VIP 视频解析 — 自动更新脚本 (CI / 本地通用)
替代 update.cmd，跨平台运行

步骤:
  1. 升级 you-get / yt-dlp
  2. 拉取上游 HTML，提取新 API 线路
  3. 合并到 api-lines.json（去重）
  4. 健康检查所有线路 → 写回 api-lines.json
  5. 重新生成 api-lines.js（含健康状态字段）

退出码: 0 = 无变更, 10 = 有变更需提交
"""

import json, re, sys, os, subprocess, time
from datetime import datetime, timezone
from urllib.request import urlopen, Request

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
JSON_PATH  = os.path.join(PROJECT_DIR, "api-lines.json")
JS_PATH    = os.path.join(PROJECT_DIR, "api-lines.js")
LOG_PATH   = os.path.join(PROJECT_DIR, "cache", "update.log")

UPSTREAM_SOURCES = [
    "https://raw.githubusercontent.com/Awle007/xshyunvip-video-player/main/index.html",
]

URL_PATTERN = re.compile(r'https?://[^"'\s<>]+')
API_PATTERN = re.compile(r'(jiexi|parse|analysis|json|m3u8|jx\.|player)')
SOCIAL_PATTERN = re.compile(r'(qq\.com|weixin|wechat|github\.com|twitter\.com|facebook\.com|weibo\.com)')


def log(msg: str):
    line = f"[{datetime.now().strftime('%H:%M:%S')}] {msg}"
    print(line)
    with open(LOG_PATH, "a", encoding="utf-8") as f:
        f.write(line + "\n")


def load_json() -> dict:
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(data: dict):
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def step1_upgrade_tools():
    """升级 you-get / yt-dlp"""
    log("=" * 50)
    log("[1/5] 升级 you-get / yt-dlp …")
    try:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "--upgrade", "you-get", "yt-dlp", "--quiet"],
            check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        log("  ✓ you-get / yt-dlp 已是最新")
    except subprocess.CalledProcessError:
        log("  ⚠ pip 升级有警告")


def step2_fetch_upstream() -> list[dict]:
    """从上游 HTML 提取 API URL"""
    log("[2/5] 拉取上游 …")
    found_urls = []
    for src in UPSTREAM_SOURCES:
        try:
            req = Request(src, headers={"User-Agent": "Mozilla/5.0"})
            with urlopen(req, timeout=15) as resp:
                html = resp.read().decode("utf-8", errors="ignore")
            urls = URL_PATTERN.findall(html)
            api_urls = [u for u in urls if API_PATTERN.search(u) and not SOCIAL_PATTERN.search(u)]
            api_urls = list(dict.fromkeys(api_urls))  # 去重保序
            log(f"  {src}  → {len(api_urls)} 条疑似线路")
            for u in api_urls:
                log(f"    {u}")
            found_urls.extend(api_urls)
        except Exception as e:
            log(f"  ⚠ 无法连接 {src}: {e}")

    # 转换为 lines 格式
    lines = []
    for i, url in enumerate(found_urls):
        # 从 URL 提取简短名称
        try:
            name = url.split("//")[1].split("/")[0].replace("jx.", "").replace("www.", "")
        except Exception:
            name = f"line_{i}"
        lines.append({"id": i + 1, "name": name, "url": url})
    return lines


def step3_merge_upstream(upstream_lines: list[dict]) -> bool:
    """合并上游线路到 api-lines.json。返回是否有新线路加入"""
    log("[3/5] 合并上游线路 …")

    data = load_json()
    new_count = 0

    for ul in upstream_lines:
        clean_url = ul["url"].rstrip("/")
        exists = any(clean_url == l["url"].rstrip("/") for l in data["lines"])
        if not exists:
            ul["id"] = len(data["lines"]) + 1 + new_count
            data["lines"].append(ul)
            new_count += 1

    if new_count:
        log(f"  +{new_count} 条新线路从上游合并")
        save_json(data)
    else:
        log("  无新线路")
    return new_count > 0


def generate_js(data: dict | None = None):
    """从 api-lines.json 生成 api-lines.js（含健康状态字段）"""
    if data is None:
        data = load_json()

    lines_json = ",\n".join(
        f'  {{"id": {l["id"]}, "name": "{l["name"]}", "url": "{l["url"]}",'
        f' "status": "{l.get("status", "ok")}",'
        f' "lastChecked": {json.dumps(l.get("lastChecked"))},'
        f' "failCount": {l.get("failCount", 0)}}}'
        for l in data["lines"]
    )
    new_js = (
        f"// auto-generated {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
        f"// edit api-lines.json, then run update.cmd or scripts/update.py\n"
        f"window.__API_LINES__ = [\n{lines_json}\n];\n"
    )
    with open(JS_PATH, "w", encoding="utf-8") as f:
        f.write(new_js)
    log("  ✓ api-lines.js 已更新")


def step4_health_check():
    """健康检查，仅在 status/failCount 变化时写回 api-lines.json。返回是否有状态变更"""
    log("[4/5] 线路健康检查 …")
    data = load_json()
    alive, dead = 0, 0
    status_changed = False
    now_utc = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    for line in data["lines"]:
        test_url = line["url"] + "https://v.qq.com"
        old_status = line.get("status")
        old_fail_count = line.get("failCount", 0)
        line["lastChecked"] = now_utc
        try:
            req = Request(test_url, headers={"User-Agent": "Mozilla/5.0"}, method="GET")
            with urlopen(req, timeout=10) as resp:
                resp.read()
            alive += 1
            line["status"] = "ok"
            line["failCount"] = 0
            log(f"  ✓ 线路{line['id']} {line['name']} OK")
        except Exception:
            dead += 1
            line["status"] = "dead"
            line["failCount"] = line.get("failCount", 0) + 1
            log(f"  ✗ 线路{line['id']} {line['name']} 超时/不可用")
        if old_status != line["status"] or old_fail_count != line["failCount"]:
            status_changed = True

    total = alive + dead
    log(f"  结果: {alive}/{total} 可用, {dead}/{total} 不可达")

    if status_changed:
        save_json(data)
        log(f"  状态已更新（{alive} 活 / {dead} 死）")
    else:
        log("  状态无变化，跳过写入")
    return status_changed


def step5_regenerate_js(json_changed: bool, health_changed: bool) -> bool:
    """在 JSON 有变更后重新生成 api-lines.js。返回是否重新生成"""
    log("[5/5] 生成 api-lines.js …")
    json_mtime = os.path.getmtime(JSON_PATH)
    js_mtime = os.path.getmtime(JS_PATH) if os.path.exists(JS_PATH) else 0
    needs_regen = json_changed or health_changed or json_mtime > js_mtime

    if needs_regen:
        generate_js()
        return True
    else:
        log("  ✓ api-lines.js 无需更新")
        return False


def main():
    os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
    log("=" * 50)
    log(f"VIP 视频解析 — 自动更新开始 ({PROJECT_DIR})")

    step1_upgrade_tools()
    upstream_lines = step2_fetch_upstream()
    json_changed = step3_merge_upstream(upstream_lines)
    health_changed = step4_health_check()
    js_changed = step5_regenerate_js(json_changed, health_changed)

    log("完成")
    changed = json_changed or js_changed
    if changed:
        log(">>> 检测到变更 <<<")
    else:
        log(">>> 无变更 <<<")
    sys.exit(0)


if __name__ == "__main__":
    main()
