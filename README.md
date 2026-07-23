# 🎬 免费看VIP视频 — GitHub 开源项目汇总

> 整理日期：2026-07-23 | 持续更新

---

## 🚀 快速开始（三种用法，按需选择）

### 🎯 方式A：浏览器即开即看（推荐，最方便）
双击 **`vip-player.html`** → 粘贴视频链接 → 点击播放。流媒体在线看，不下载任何文件。

### 🎯 方式B：PotPlayer 边播边看（画质更好）
```batch
cd /d d:\vip_free\vip-video-resources

:: 默认线路1，播不了换线路 (1-9)
stream.cmd "https://v.qq.com/x/cover/xxx.html"
stream.cmd "https://v.qq.com/x/cover/xxx.html" 3
```
同样是流媒体播放，不保存文件。PotPlayer 内置视频嗅探，画质优于浏览器。

### 🎯 方式C：下载到本地（最高画质，离线观看）
```batch
:: 先看有哪些画质
info.cmd "https://v.qq.com/x/cover/xxx.html"
:: 下载最高画质
play.cmd "https://v.qq.com/x/cover/xxx.html"
```
下载完毕后在 `downloads/` 目录，用 PotPlayer 打开。

### 📁 项目文件结构

```
vip-video-resources/
├── vip-player.html          ← 网页解析器（粘贴即播，不下载）
├── stream.cmd               ← 边播边看 — 解析后用 PotPlayer 流媒体播放
├── play.cmd                 ← 下载最高画质到本地
├── info.cmd                 ← 查看视频有哪些画质
├── you-get.cmd              ← you-get 完整下载功能
├── n_m3u8dl.cmd             ← N_m3u8DL-RE 下载（支持4K）
├── downloads/               ← 下载的视频保存位置
├── cache/                   ← 工具缓存
├── tools/
│   ├── N_m3u8DL-RE/        ← N_m3u8DL-RE v0.6.0-beta
│   └── ffmpeg/             ← ffmpeg
├── README.md
├── self-parse-guide.md
└── .gitignore
```

---

## 📖 目录

1. [方式一：网页版在线解析（推荐，零安装）](#方式一网页版在线解析)
2. [方式二：油猴脚本（浏览器插件）](#方式二油猴脚本)
3. [方式三：桌面客户端](#方式三桌面客户端)
4. [方式四：TV盒子 / 手机端](#方式四tv盒子--手机端)
5. [开源解析接口汇总](#开源解析接口)
6. [特别提示](#特别提示)

---

## 方式一：网页版在线解析

> **最简单，无需安装任何东西。** 打开网页 → 粘贴VIP视频链接 → 播放。

### 已制作好的本地网页

直接用浏览器打开本目录下的 **[vip-player.html](vip-player.html)**，即可使用。

### GitHub 开源项目

| 项目 | ⭐ Stars | 说明 | 链接 |
|------|--------|------|------|
| **Jiangmenghao/vip-video-player** | 热门 | 纯静态前端，无需后端，支持腾讯/优酷/爱奇艺/芒果TV | [GitHub](https://github.com/Jiangmenghao/vip-video-player) |
| **Awle007/xshyunvip-video-player** | 活跃 | 上者的活跃 Fork，2025 年持续更新，新增搜索站、播放历史等 | [GitHub](https://github.com/Awle007/xshyunvip-video-player) |
| **Qikaile/video** | 新 | 云生VIP视频解析网站，纯静态前端 | [GitHub](https://github.com/Qikaile/video) |
| **Yu-dongxing/DW-HTML** | 入门级 | VIP视频解析网站，支持 M3U8 链接 | [GitHub](https://github.com/Yu-dongxing/DW-HTML) |

**在线演示站（可直接使用）：**
- `https://vip.heimaokeji.xyz` — Jiangmenghao 的演示站
- `https://91xcode.github.io/vip-video-parse/index.html` — 全网VIP视频在线播放
- `https://go.88lin.eu.org/vip/index.html` — 88lin 的云解析站

### 原理

网页通过第三方解析接口（API）获取视频的真实 M3U8 流地址，然后在浏览器中播放。网页本身不存储/中转任何视频内容。

```
你粘贴的链接  →  第三方解析API  →  返回真实视频流  →  浏览器播放
https://v.qq.com/xxx  →  jx.m3u8.tv/jiexi/?url=xxx  →  m3u8流  →  播放器渲染
```

---

## 方式二：油猴脚本

> 安装后在视频网站页面直接出现「VIP解析」按钮，无需离开原网站。

| 项目 | ⭐ Stars | 说明 | 链接 |
|------|--------|------|------|
| **88lin/video_vip** | ⭐⭐⭐⭐⭐ 热门 | 功能最全的油猴脚本，长期维护更新 | [GitHub](https://github.com/88lin/video_vip) |

**使用方法：**
1. 浏览器安装 [Tampermonkey](https://www.tampermonkey.net/) 扩展
2. 安装脚本：[video_vip.user.js](https://cdn.jsdelivr.net/gh/88lin/video_vip@main/video_vip.user.js)
3. 打开腾讯视频/爱奇艺等网站，页面左侧会出现「VIP」按钮
4. 点击按钮选择解析线路即可

**优点：** 直接在原网站上操作，体验最流畅
**缺点：** 需要装浏览器扩展

---

## 方式三：桌面客户端

| 项目 | ⭐ Stars | 平台 | 说明 | 链接 |
|------|--------|------|------|------|
| **ZY-Player** (Hunlongyu) | ~14.5k | Win/Mac/Linux | 经典跨平台桌面播放器，Electron+Vue | [GitHub](https://github.com/Hunlongyu/ZY-Player) |
| **ZyPlayer** (Hiram-Wong) | ~8.5k | Win/Mac/Linux | ZY-Player 活跃分支，2026年持续更新到 v3.4.6 | [GitHub](https://github.com/Hiram-Wong/ZyPlayer) |
| **iodefog/VipVideo** | 热门 | Win/Mac | 聚合App，视频+音乐+直播+小说 | [GitHub](https://github.com/iodefog/VipVideo) |
| **yzutyc/video-vip** (henVIP) | 新 | Win | Python GUI/CLI 版本，支持多平台解析 | [GitHub](https://github.com/yzutyc/video-vip) |
| **SunboyGo/VipVideo1** | - | Mac | macOS 端VIP视频聚合App | [GitHub](https://github.com/SunboyGo/VipVideo1) |

---

## 方式四：TV盒子 / 手机端

> 适合在电视/盒子上使用，需要安装 APK。

### 播放器APP

| 项目 | 说明 | 链接 |
|------|------|------|
| **FongMi/TV** | ⭐ 最多，最活跃，支持直播多线路、自动换源 | [GitHub](https://github.com/FongMi/TV) |
| **catvod/CatVodOpen** | 猫影视，跨平台最精简，支持多平台 | [GitHub](https://github.com/catvod/CatVodOpen) |
| **takagen99/Box** | TVBox 分支，UI 美观，支持直播回放 | [GitHub](https://github.com/takagen99/Box) |
| **CatVodTVOfficial/TVBoxOSC** | TVBox 原版 | [GitHub](https://github.com/CatVodTVOfficial/TVBoxOSC) |
| **XiaoRanLiu3119/TVBoxOS-Mobile** | 手机竖屏版 | [GitHub](https://github.com/XiaoRanLiu3119/TVBoxOS-Mobile) |
| **Jiangmenghao/susan** | Android VIP视频解析App | [GitHub](https://github.com/Jiangmenghao/susan) |

### TVBox 配置源（接口）

| 项目 | ⭐ | 说明 | 链接 |
|------|-----|------|------|
| **qist/tvbox** | 热门 | OK影视、TVBox配置，最全源整理 | [GitHub](https://github.com/qist/tvbox) |
| **gaotianliuyun/gao** | 热门 | FongMi影视和tvbox配置文件 | [GitHub](https://github.com/gaotianliuyun/gao) |
| **zhiyuan411/TVBox-Suite** | 新 | TVBox源管理系统，含2026最新接口 | [GitHub](https://github.com/zhiyuan411/TVBox-Suite) |
| **dlgt7/TVbox-interface** | - | TVBox使用教程+接口整理 | [GitHub](https://github.com/dlgt7/TVbox-interface) |
| **noimank/tvbox** | - | 自用tvbox源+影视仓多仓源 | [GitHub](https://github.com/noimank/tvbox) |

---

## 开源解析接口

以下是常用的第三方视频解析 API（用于网页解析器）：

| 线路 | API 地址 |
|------|---------|
| 线路1 | `https://jx.m3u8.tv/jiexi/?url=` |
| 线路2 | `https://jx.ppflv.com/?url=` |
| 线路3 | `https://json.pangujiexi.com:12345/json.php?url=` |
| 线路4 | `https://api.parwix.com:4433/analysis/json/?url=` |
| 线路5 | `https://jx.playerjy.com/?url=` |
| 线路6 | `https://jx.aidouer.net/?url=` |
| 线路7 | `https://jx.nnxv.cn/tv.php?url=` |
| 线路8 | `https://jx.xmflv.com/?url=` |
| 线路9 | `https://jx.yangtu.tv/?url=` |

使用方式：`接口地址 + 视频链接URL`

---

## 支持的主要平台

| 平台 | 网址 | VIP内容 |
|------|------|---------|
| 腾讯视频 | v.qq.com | 会员专享剧集/电影 |
| 爱奇艺 | iqiyi.com | 会员专享内容 |
| 优酷 | youku.com | 会员专享内容 |
| 芒果TV | mgtv.com | 会员综艺/剧集 |
| 哔哩哔哩 | bilibili.com | 大会员番剧 |
| 搜狐视频 | tv.sohu.com | 会员内容 |
| PPTV | pptv.com | 体育/影视会员 |

---

## 特别提示

1. **仅供学习参考** — 所有工具和接口仅供学习前端/网络技术使用，请于24小时内删除
2. **支持正版** — 如果喜欢某个内容，请购买正版会员支持创作者
3. **接口不稳定** — 第三方解析接口可能随时失效，如无法播放请切换线路
4. **注意广告** — 解析页面可能包含第三方广告，请勿轻信充值/下载/加群等诱导信息
5. **推荐搭配 AdGuard** — 使用 [AdGuard](https://adguard.com) 广告拦截器获得更干净的体验
