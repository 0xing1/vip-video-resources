// ==UserScript==
// @name         VIP视频免费解析跳转
// @namespace    https://github.com/0xing1/vip-video-resources
// @version      1.1.0
// @description  在VIP视频平台页面注入浮动按钮，一键跳转到免费解析播放（线路自动从 GitHub 同步）
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
// @icon         https://v.qq.com/favicon.ico
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_registerMenuCommand
// @grant        GM_getResourceText
// @grant        GM_xmlhttpRequest
// @resource     LINES https://raw.githubusercontent.com/0xing1/vip-video-resources/main/api-lines.json
// @downloadURL  https://raw.githubusercontent.com/0xing1/vip-video-resources/main/tampermonkey/vip-parser-jump.user.js
// @updateURL    https://raw.githubusercontent.com/0xing1/vip-video-resources/main/tampermonkey/vip-parser-jump.user.js
// @run-at       document-end
// ==/UserScript==

(function () {
  'use strict';

  // ── 应急线路（仅当网络拉取失败时使用，至少保留 5 条最稳定线路） ──
  const FALLBACK_LINES = [
    { id: 1,  name: 'playerjy',    url: 'https://jx.playerjy.com/?url=' },
    { id: 5,  name: '爱豆',         url: 'https://jx.aidouer.net/?url=' },
    { id: 11, name: 'm3u8.tv',     url: 'https://jx.m3u8.tv/jiexi/?url=' },
    { id: 14, name: '虾米解析',      url: 'https://jx.xmflv.com/?url=' },
    { id: 20, name: 'HLS解析',      url: 'https://jx.hls.one/?url=' },
  ];

  // ── 状态 ──
  const STORE_KEY = 'vip_parser_line_idx';
  const LINES_CACHE_KEY = 'vip_parser_lines_cache';
  const LINES_CACHE_TS_KEY = 'vip_parser_lines_ts';
  const CACHE_TTL = 60 * 60 * 1000; // 1 小时

  let API_LINES = [];
  let currentIdx = 0;

  function getCurrentApi() {
    if (!API_LINES.length) return FALLBACK_LINES[0].url;
    if (currentIdx >= API_LINES.length) currentIdx = 0;
    return API_LINES[currentIdx].url;
  }

  function getCurrentName() {
    if (!API_LINES.length) return '应急线路';
    if (currentIdx >= API_LINES.length) currentIdx = 0;
    return '线路' + API_LINES[currentIdx].id + ' ' + API_LINES[currentIdx].name;
  }

  // ── 解析线路数据 ──
  function parseLines(raw) {
    try {
      const data = JSON.parse(raw);
      if (data && data.lines && data.lines.length) return data.lines;
    } catch (e) {}
    return null;
  }

  function loadCachedLines() {
    try {
      const ts = GM_getValue(LINES_CACHE_TS_KEY, 0);
      if (Date.now() - ts < CACHE_TTL) {
        const cached = GM_getValue(LINES_CACHE_KEY, '');
        if (cached) {
          const lines = parseLines(cached);
          if (lines) return lines;
        }
      }
    } catch (e) {}
    return null;
  }

  function saveCachedLines(raw) {
    try {
      GM_setValue(LINES_CACHE_KEY, raw);
      GM_setValue(LINES_CACHE_TS_KEY, Date.now());
    } catch (e) {}
  }

  function loadLines(callback) {
    // 1. 优先用 @resource（Tampermonkey 安装时内嵌版本）
    try {
      const raw = GM_getResourceText('LINES');
      const lines = parseLines(raw);
      if (lines) {
        API_LINES = lines;
        saveCachedLines(raw);
        callback();
        return;
      }
    } catch (e) {}

    // 2. 尝试本地缓存
    const cached = loadCachedLines();
    if (cached) {
      API_LINES = cached;
      callback();
      // 后台异步拉取最新版本
      fetchLatestInBackground();
      return;
    }

    // 3. 实时拉取
    fetchLatest(function (lines) {
      if (lines) {
        API_LINES = lines;
      } else {
        API_LINES = FALLBACK_LINES;
      }
      callback();
    });
  }

  function fetchLatestInBackground() {
    GM_xmlhttpRequest({
      method: 'GET',
      url: 'https://raw.githubusercontent.com/0xing1/vip-video-resources/main/api-lines.json',
      timeout: 5000,
      onload: function (resp) {
        const lines = parseLines(resp.responseText);
        if (lines) {
          API_LINES = lines;
          saveCachedLines(resp.responseText);
          if (currentIdx >= API_LINES.length) currentIdx = 0;
          GM_setValue(STORE_KEY, currentIdx);
          updateLabel();
        }
      },
      onerror: function () {}
    });
  }

  function fetchLatest(callback) {
    GM_xmlhttpRequest({
      method: 'GET',
      url: 'https://raw.githubusercontent.com/0xing1/vip-video-resources/main/api-lines.json',
      timeout: 8000,
      onload: function (resp) {
        const lines = parseLines(resp.responseText);
        if (lines) {
          saveCachedLines(resp.responseText);
          callback(lines);
        } else {
          callback(null);
        }
      },
      onerror: function () { callback(null); },
      ontimeout: function () { callback(null); }
    });
  }

  // ── 生成解析链接 ──
  function buildParseUrl() {
    const videoUrl = encodeURIComponent(location.href);
    return getCurrentApi() + videoUrl;
  }

  // ── 切换线路 ──
  function switchLine() {
    if (!API_LINES.length) {
      API_LINES = FALLBACK_LINES;
    }
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

  function forceRefreshLines() {
    fetchLatest(function (lines) {
      if (lines) {
        API_LINES = lines;
        currentIdx = 0;
        GM_setValue(STORE_KEY, currentIdx);
        updateLabel();
        toast('✅ 线路已更新（' + API_LINES.length + ' 条）');
      } else {
        toast('⚠️ 更新失败，请检查网络');
      }
    });
  }

  // ── GM 菜单 ──
  GM_registerMenuCommand('🔄 切换解析线路', () => {
    switchLine();
    updateLabel();
    alert('已切换至: ' + getCurrentName());
  });

  GM_registerMenuCommand('📋 查看当前线路', () => {
    alert('当前: ' + getCurrentName() + '\n共 ' + API_LINES.length + ' 条线路');
  });

  GM_registerMenuCommand('🔃 强制更新线路列表', () => {
    forceRefreshLines();
  });

  // ── 启动 ──
  function boot() {
    loadLines(function () {
      const saved = GM_getValue(STORE_KEY, 0);
      currentIdx = (saved < API_LINES.length) ? saved : 0;
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', createFloatingBtn);
      } else {
        createFloatingBtn();
      }
    });
  }

  boot();

})();
