# 自建视频解析教程

> 不依赖第三方接口，自己从视频平台拿到真实 M3U8 流地址，用本地播放器看最高画质。

---

## 原理图解

```
┌─────────────────────────────────────────────────────────────────┐
│  第三方接口方式（之前的网页）                                       │
│                                                                   │
│  你 ──→ 第三方服务器 ──→ 腾讯/爱奇艺 ──→ 第三方服务器 ──→ 你       │
│                                      ↑                            │
│                              用的是别人的会员Cookie                │
│                              画质由别人决定（通常720P）             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  自建解析（本教程）                                                │
│                                                                   │
│  你 ──→ your-get/N_m3u8DL ──→ 腾讯/爱奇艺 ──→ 真实M3U8地址        │
│                                                         ↓         │
│                                                    VLC/PotPlayer  │
│                                                    最高画质播放     │
│                                                                   │
│  解析工具逆向模拟了官方App的请求过程，向平台API直接请求最高清流      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 方法一：you-get（最简单，推荐入门）

### 安装

```bash
# Windows：打开 PowerShell 或 Git Bash，执行：
pip install you-get

# 如果没装 Python，先去 https://python.org 下载安装（勾选 Add to PATH）
```

### 基础用法

```bash
# 1. 查看视频有哪些画质可选
you-get -i "https://v.qq.com/x/cover/xxxxx.html"

# 输出示例：
# format:        format_key:     size:
# 蓝光1080P      fhd            1200 MB
# 超清720P       shd            800 MB
# 高清480P       hd             500 MB
# 标清270P       sd             300 MB

# 2. 选择最高画质下载
you-get --format=fhd "https://v.qq.com/x/cover/xxxxx.html"

# 3. 下载指定集数
you-get --format=fhd -o ./downloads "https://v.qq.com/x/cover/xxxxx.html"

# 4. ⭐ 下载的同时用本地播放器播放（边下边看）
you-get --player=potplayer "https://v.qq.com/x/cover/xxxxx.html"
# 或者用 mpv（最轻量）
you-get --player=mpv "https://v.qq.com/x/cover/xxxxx.html"
# 或者用 VLC
you-get --player=vlc "https://v.qq.com/x/cover/xxxxx.html"
```

### 支持的平台

```bash
# 腾讯视频
you-get "https://v.qq.com/x/cover/xxxxx.html"

# 爱奇艺
you-get "https://www.iqiyi.com/v_xxxxx.html"

# 优酷
you-get "https://v.youku.com/v_show/id_xxxxx.html"

# 芒果TV
you-get "https://www.mgtv.com/b/xxxxx/xxxxx.html"

# B站
you-get "https://www.bilibili.com/video/BVxxxxx"

# 搜狐、PPTV、YouTube 等几十个平台
```

### 注意

- you-get 对**免费视频**效果最好，能直接拿到最高画质
- 对**纯VIP视频**（不登录完全不让看的），需要配合 Cookie 使用：

```bash
# 从浏览器导出 Cookie（需要先登录你的会员账号）
you-get -c cookies.txt "https://v.qq.com/x/cover/xxxxx.html"
```

---

## 方法二：N_m3u8DL-RE（功能最强）

```
GitHub: https://github.com/nilaoda/N_m3u8DL-RE
⭐ 45k+ Stars | 持续更新 | 支持 Windows/Mac/Linux
```

### 安装

从 [Releases 页面](https://github.com/nilaoda/N_m3u8DL-RE/releases) 下载最新版：
- Windows: `N_m3u8DL-RE_windows_xxx.zip`
- Mac: `N_m3u8DL-RE_osx_xxx.tar.gz`

解压即可用，无需安装。

### 带图形界面（推荐）

下载 **含 GUI 版本**（文件名带 `-GUI`），打开后：

1. 粘贴视频链接到输入框
2. 自动识别出所有画质选项
3. 勾选想要的画质
4. 点击"开始下载"

```
┌──────────────────────────────────────┐
│  N_m3u8DL-RE GUI                     │
│                                      │
│  URL: [https://v.qq.com/xxx      ]   │
│                                      │
│  ☑ 4K (2160P)   - 3.2 GB            │
│  ☐ 1080P        - 1.5 GB            │
│  ☐ 720P         - 800 MB            │
│                                      │
│  保存到: [D:\Downloads          ]    │
│                                      │
│  [ 开始下载 ]                        │
└──────────────────────────────────────┘
```

### 命令行高级用法

```bash
# 列出所有画质
N_m3u8DL-RE "https://v.qq.com/x/cover/xxx.html" --list-quality

# 自动选最高画质
N_m3u8DL-RE "https://v.qq.com/x/cover/xxx.html" -sv best

# 选特定画质（如 1080P）
N_m3u8DL-RE "https://v.qq.com/x/cover/xxx.html" -sv "1080P"

# 只解析不下载（只输出 M3U8 地址）
N_m3u8DL-RE "https://v.qq.com/x/cover/xxx.html" --skip-download

# 下载整个剧集
N_m3u8DL-RE "https://v.qq.com/x/cover/xxx.html" -mt -M format=mp4

# 用本地播放器实时播放
N_m3u8DL-RE "https://v.qq.com/x/cover/xxx.html" --live-real-time-merge
```

---

## 方法三：手动抓包（学习原理）

用浏览器开发者工具自己找到真实视频地址，零依赖。

### 步骤

```
1. F12 打开开发者工具 → Network（网络）标签
2. 在过滤框输入 "m3u8" 或 ".ts"
3. 刷新页面，播放视频（哪怕是试看6分钟）
4. 在网络请求列表中找到 m3u8 文件：
   ┌─────────────────────────────────────────────────────┐
   │ Name                    Type        Size    Time    │
   │ playlist.m3u8           x-mpegURL   2.1KB   230ms   │  ← 这就是真实视频流！
   │ segment-001.ts          x-mpegURL   4.5MB   120ms   │
   │ segment-002.ts          x-mpegURL   5.1MB   115ms   │
   └─────────────────────────────────────────────────────┘
5. 右键 playlist.m3u8 → Copy URL
6. 打开 VLC/PotPlayer → 打开网络流 → 粘贴地址 → 播放
```

### 但这只能拿到试看6分钟的流

要拿到完整视频，需要**注入会员 Cookie**：

1. 找一个有会员的朋友，登录后导出 Cookie（EditThisCookie 等浏览器插件可导出）
2. 在命令行用 curl 带上 Cookie 请求：

```bash
# 把 Cookie 字符串替换进去
curl -H "Cookie: 导出的cookie内容" \
  "https://v.qq.com/x/cover/xxx.html" \
  | grep -oP 'playlist[^"]+m3u8[^"]+'
```

3. 拿到的完整 M3U8 地址用 VLC 直接播放

---

## 方法四：File Centipede（图形界面，零代码）

```
GitHub: https://github.com/filecxx/FileCentipede
⭐ 9k+ Stars | 纯 GUI | 支持所有平台
```

跟 IDM（Internet Download Manager）类似的操作体验：
1. 下载安装 → 打开
2. 复制视频链接 → 自动弹出下载窗口
3. 列出所有画质 → 选最高 → 点下载
4. 支持**边下边播**

---

## 文件结构

```
vip-video-resources/
├── vip-player.html          ← 网页解析器（粘贴即播，依赖第三方接口）
├── README.md                ← GitHub 开源项目汇总
└── self-parse-guide.md      ← 本文件（自建解析教程）
```

---

## 总结对比

| 方案 | 画质 | 难度 | 速度 | 适用场景 |
|------|------|------|------|---------|
| **网页解析器** (vip-player.html) | 480P~720P | ⭐ | 快 | 随便看看，不追求画质 |
| **you-get** | 最高1080P | ⭐⭐ | 快 | 命令行用户，快速获取高清 |
| **N_m3u8DL-RE GUI** | 4K | ⭐ | 快 | ⭐推荐，图形界面首选 |
| **手动抓包** | 取决于Cookie | ⭐⭐⭐⭐ | 最快 | 学习原理，精准控制 |
| **TVBox + 阿里云盘** | 4K原画 | ⭐⭐⭐ | 快 | 电视大屏场景 |

> 💡 **推荐路径**：入门用 N_m3u8DL-RE GUI（有图形界面），进阶用 you-get（命令行自动化），需要电视看就上 TVBox。
