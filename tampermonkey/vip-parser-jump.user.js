// ==UserScript==
// @name         VIP视频免费解析跳转
// @namespace    https://github.com/0xing1/vip-video-resources
// @version      1.0.0
// @description  在VIP视频平台页面注入浮动按钮，一键跳转到免费解析播放
// @author       0xing1
// @match        https://v.qq.com/*
// @match        https://www.iqiyi.com/*
// @match        https://www.iq.com/*
// @match        https://www.youku.com/*
// @match        https://www.mgtv.com/*
// @match        https://www.bilibili.com/*
// @match        https://tv.sohu.com/*
// @match        https://www.pptv.com/*
// @match        https://www.1905.com/*
// @match        https://www.le.com/*
// @icon         https://www.google.com/s2/favicons?domain=v.qq.com
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_registerMenuCommand
// @run-at       document-end
// ==/UserScript==

(function () {
  'use strict';

  // ── 解析线路配置（与 api-lines.json 保持同步） ──
  const API_LINES = [
    { id: 1,  name: 'playerjy',    url: 'https://jx.playerjy.com/?url=' },
    { id: 2,  name: '夜幕',         url: 'https://www.yemu.xyz/?url=' },
    { id: 3,  name: '极速解析',      url: 'https://jx.2s0.cn/player/?url=' },
    { id: 4,  name: 'Node解析',     url: 'https://jx.nodenode.dpdns.org/?url=' },
    { id: 5,  name: '爱豆',         url: 'https://jx.aidouer.net/?url=' },
    { id: 6,  name: '789解析',      url: 'https://jiexi.789jiexi.icu:4433/?url=' },
    { id: 7,  name: 'playm3u8',    url: 'https://www.playm3u8.cn/jiexi.php?url=' },
    { id: 8,  name: 'Yparse',      url: 'https://jx.yparse.com/index.php?url=' },
    { id: 9,  name: '剖元解析',      url: 'https://www.pouyun.com/?url=' },
    { id: 10, name: 'CK',          url: 'https://www.ckplayer.vip/jiexi/?url=' },
    { id: 11, name: 'm3u8.tv',     url: 'https://jx.m3u8.tv/jiexi/?url=' },
    { id: 12, name: 'super.playr',  url: 'https://super.playr.top/?url=' },
    { id: 13, name: '盘古',         url: 'https://www.pangujiexi.com/jiexi/?url=' },
    { id: 14, name: '虾米解析',      url: 'https://jx.xmflv.com/?url=' },
    { id: 15, name: '七七云',       url: 'https://jx.77flv.cc/?url=' },
    { id: 16, name: '冰豆解析',      url: 'https://bd.jx.cn/?url=' },
    { id: 17, name: '973解析',      url: 'https://jx.973973.xyz/?url=' },
    { id: 18, name: 'nnxv',        url: 'https://jx.nnxv.cn/tv.php?url=' },
    { id: 19, name: 'fongmi(JSON)',url: 'https://json.fongmi.cc/web?url=' },
    { id: 20, name: 'HLS解析',      url: 'https://jx.hls.one/?url=' },
    { id: 21, name: '芒果专用1',     url: 'https://video.isyour.love/player/getplayer?url=' },
    { id: 22, name: '芒果专用2',     url: 'https://im1907.top/?jx=' },
  ];

  // ── 智能检测：如果本地有 vip-player.html，优先用它；否则直连 API ──
  const LOCAL_PLAYER = 'http://127.0.0.1:5500/vip-player.html'; // VS Code Live Server
  const USE_LOCAL = false; // 改为 true 启用本地播放器

  // ── 状态 ──
  const STORE_KEY = 'vip_parser_line_idx';
  let currentIdx = GM_getValue(STORE_KEY, 0);
  if (currentIdx >= API_LINES.length) currentIdx = 0;

  function getCurrentApi() {
    return API_LINES[currentIdx].url;
  }

  function getCurrentName() {
    return `线路${API_LINES[currentIdx].id} ${API_LINES[currentIdx].name}`;
  }

  // ── 生成解析链接 ──
  function buildParseUrl() {
    const videoUrl = encodeURIComponent(location.href);
    if (USE_LOCAL) {
      return `${LOCAL_PLAYER}?url=${videoUrl}&api=${encodeURIComponent(getCurrentApi())}`;
    }
    return getCurrentApi() + videoUrl;
  }

  // ── 切换线路 ──
  function switchLine() {
    currentIdx = (currentIdx + 1) % API_LINES.length;
    GM_setValue(STORE_KEY, currentIdx);
    updateLabel();
  }

  // ── 浮动按钮 UI ──
  function createFloatingBtn() {
    const container = document.createElement('div');
    container.id = 'vip-parser-container';
    container.innerHTML = `
      <style>
        #vip-parser-container {
          position: fixed;
          bottom: 80px;
          right: 20px;
          z-index: 999999;
          display: flex;
          flex-direction: column;
          gap: 8px;
          font-family: -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Microsoft YaHei', sans-serif;
        }
        .vip-btn {
          width: 52px;
          height: 52px;
          border-radius: 50%;
          border: none;
          cursor: pointer;
          font-size: 20px;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: all .25s;
          box-shadow: 0 4px 16px rgba(233,69,96,.35);
          position: relative;
        }
        .vip-btn-main {
          background: linear-gradient(135deg, #e94560, #ff6b81);
          color: #fff;
        }
        .vip-btn-main:hover {
          transform: scale(1.1);
          box-shadow: 0 6px 24px rgba(233,69,96,.5);
        }
        .vip-btn-main:active {
          transform: scale(.92);
        }
        .vip-btn-switch {
          width: 36px;
          height: 36px;
          background: rgba(26,26,46,.85);
          color: #ccc;
          font-size: 14px;
          box-shadow: 0 2px 10px rgba(0,0,0,.4);
          backdrop-filter: blur(10px);
          border: 1px solid rgba(255,255,255,.1);
          align-self: center;
        }
        .vip-btn-switch:hover {
          background: rgba(233,69,96,.25);
          color: #fff;
          border-color: #e94560;
        }
        .vip-label {
          position: absolute;
          right: 60px;
          top: 50%;
          transform: translateY(-50%);
          background: rgba(0,0,0,.85);
          color: #fff;
          font-size: 12px;
          padding: 6px 12px;
          border-radius: 6px;
          white-space: nowrap;
          pointer-events: none;
          opacity: 0;
          transition: opacity .2s;
          backdrop-filter: blur(6px);
        }
        .vip-btn-main:hover .vip-label {
          opacity: 1;
        }
        .vip-toast {
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%,-50%);
          background: rgba(0,0,0,.88);
          color: #fff;
          padding: 12px 24px;
          border-radius: 10px;
          font-size: 14px;
          z-index: 9999999;
          pointer-events: none;
          animation: vipFadeOut 2s ease forwards;
        }
        @keyframes vipFadeOut {
          0%, 60% { opacity: 1; }
          100% { opacity: 0; }
        }
      </style>
      <button class="vip-btn vip-btn-switch" id="vip-switch-btn" title="切换解析线路">🔄</button>
      <button class="vip-btn vip-btn-main" id="vip-play-btn" title="免费解析播放">
        🔓
        <span class="vip-label" id="vip-line-label">${getCurrentName()}</span>
      </button>
    `;
    document.body.appendChild(container);

    document.getElementById('vip-play-btn').addEventListener('click', () => {
      const url = buildParseUrl();
      window.open(url, '_blank');
      toast('🚀 正在打开解析页面...');
    });

    document.getElementById('vip-switch-btn').addEventListener('click', () => {
      switchLine();
      toast('✅ 已切换: ' + getCurrentName());
    });
  }

  function updateLabel() {
    const label = document.getElementById('vip-line-label');
    if (label) label.textContent = getCurrentName();
  }

  function toast(msg) {
    const el = document.createElement('div');
    el.className = 'vip-toast';
    el.textContent = msg;
    document.body.appendChild(el);
    setTimeout(() => el.remove(), 2100);
  }

  // ── GM 菜单：切换线路 ──
  GM_registerMenuCommand('🔄 切换解析线路', () => {
    switchLine();
    updateLabel();
    alert('已切换至: ' + getCurrentName());
  });

  GM_registerMenuCommand('📋 查看当前线路', () => {
    alert('当前: ' + getCurrentName());
  });

  // ── 启动 ──
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', createFloatingBtn);
  } else {
    createFloatingBtn();
  }

})();
