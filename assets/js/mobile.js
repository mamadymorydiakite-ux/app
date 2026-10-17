/* ============================================================
   Link — Android mobile mockup behaviour
   ============================================================ */
(function () {
  'use strict';
  var U = window.LinkUI;
  var $ = U.$, $$ = U.$$, esc = U.esc;

  document.body.classList.toggle('in-frame', window.self !== window.top);
  U.fit($('#phone'), 390, 844);

  /* ---------------- Mock data ---------------- */
  var DATA = {
    recent: [
      { name: 'presentation.pdf', size: '24.5 MB', dir: 'up', pct: 73, status: 'sending' },
      { name: 'holiday-photo.jpg', size: '4.8 MB', dir: 'up', pct: 100, status: 'done' },
      { name: 'meeting-notes.txt', size: '12 KB', dir: 'down', pct: 100, status: 'done' },
      { name: 'project-assets.zip', size: '128 MB', dir: 'down', pct: 100, status: 'done' }
    ],
    queue: [
      { name: 'budget-q3.xlsx', size: '1.2 MB', dir: 'up', state: 'Waiting' },
      { name: 'screenshot-2026.png', size: '860 KB', dir: 'up', state: 'Waiting' }
    ],
    clipboard: {
      phone: [
        { time: 'Just now', text: 'Meet me at the library at 6pm — the one next to the park.', glyph: 'clipboard' },
        { time: '12 min ago', text: '192.168.1.42', glyph: 'hash' },
        { time: '1 hour ago', text: 'Holiday packing list: passport, charger, adapter, headphones, sunglasses.', glyph: 'clipboard' }
      ],
      pc: [
        { time: 'Just now', text: 'https://docs.local/link-offline-first-notes', glyph: 'globe' },
        { time: '26 min ago', text: 'SELECT * FROM transfers WHERE device = "pixel-8-pro";', glyph: 'clipboard' },
        { time: '2 hours ago', text: 'Sprint review moved to Thursday 10:30 — room Ada.', glyph: 'clipboard' }
      ]
    },
    history: [
      { name: 'Desktop-PC', meta: 'Today · 2h 34m · 156 MB', badge: 'Active', live: true },
      { name: 'Workstation-2', meta: 'Yesterday · 41m · 22 MB', live: false },
      { name: 'Desktop-PC', meta: '2 days ago · 1h 08m · 310 MB', live: false }
    ],
    settings: [
      { title: 'General', rows: [
        { label: 'Language', desc: 'Interface language', type: 'value', value: 'English (US)' },
        { label: 'Start on boot', desc: 'Open Link when the phone starts', type: 'switch', on: true },
        { label: 'Notifications', desc: 'Transfer and connection alerts', type: 'switch', on: true },
        { label: 'Keep screen awake while connected', type: 'switch', on: false }
      ] },
      { title: 'Connection', rows: [
        { label: 'Preferred port', desc: 'Local listening port', type: 'value', value: '8080' },
        { label: 'Connection timeout', type: 'value', value: '30 seconds' },
        { label: 'Auto-reconnect on Wi-Fi change', type: 'switch', on: true }
      ] },
      { title: 'Security', rows: [
        { label: 'Pairing PIN', desc: 'Shown on both devices', type: 'value', value: '•••• 4 8 2' },
        { label: 'Require PIN for pairing', type: 'switch', on: true },
        { label: 'Local TLS encryption', desc: 'Encrypt traffic between devices', type: 'switch', on: true },
        { label: 'Allowed devices', desc: 'Devices allowed to pair automatically', type: 'link', value: '2 devices' }
      ] },
      { title: 'About', rows: [
        { label: 'Version', desc: 'Link for Android', type: 'value', value: '1.0.0 (stable)' },
        { label: 'Open-source licences', type: 'link', value: 'View' },
        { label: 'Storage used by transfers', type: 'value', value: '12.4 MB' }
      ] },
      { title: 'Prototype', demo: true, rows: [] }
    ]
  };

  /* ---------------- Store + screen routing ---------------- */
  var api = U.store({ status: 'disconnected', screen: 'home', ip: '192.168.1.42', clipTab: 'phone' });

  var NAV = {
    home: 'home', dashboard: 'home', files: 'files', transfer: 'files',
    clipboard: 'clipboard', tools: 'tools', keyboard: 'tools', touchpad: 'tools',
    ring: 'tools', devices: 'tools', screencast: 'tools', settings: 'settings',
    scan: null, connecting: null, error: null
  };
  var BARE = { scan: 1, connecting: 1, error: 1 };
  var REP = { disconnected: 'home', connecting: 'connecting', connected: 'dashboard', error: 'error' };

  function currentScreen() { return api.get('screen'); }

  function go(name, opts) {
    if (name === 'home' && api.get('status') === 'connected') name = 'dashboard';
    if (name === 'dashboard' && api.get('status') !== 'connected') name = 'home';
    if (!NAV.hasOwnProperty(name)) name = 'home';

    var prev = currentScreen();
    var from = (opts && opts.from) || NAV[prev];
    $$('.screen').forEach(function (s) { s.classList.remove('active'); });
    var target = document.getElementById('s-' + name);
    if (target) target.classList.add('active');

    var tab = NAV[name] || from;
    $$('.tabitem').forEach(function (b) { b.classList.toggle('active', b.getAttribute('data-tab') === tab); });
    $('#tabbar').hidden = !!BARE[name];
    $('#phone').classList.toggle('on-dark', name === 'scan');
    $('#content').classList.toggle('dark-scroll', name === 'scan');
    $('#content').scrollTop = 0;
    api.set({ screen: name, lastTab: tab });
    onEnter(name);
  }

  function setState(status, navigate) {
    api.set({ status: status });
    if (navigate) go(REP[status] || 'home');
  }

  api.sub(function (state, patch) {
    if (!('status' in patch)) return;
    var s = state.status, cur = currentScreen();
    if (s === 'connecting') go('connecting');
    else if (s === 'connected') { if (cur === 'home' || cur === 'connecting' || cur === 'error') go('dashboard'); }
    else if (s === 'error') { if (cur === 'home' || cur === 'connecting') go('error'); }
    else if (s === 'disconnected') { if (cur === 'dashboard' || cur === 'connecting' || cur === 'error') go('home'); }
    syncChrome();
  });

  function syncChrome() {
    var s = api.get('status');
    $('#localChip').hidden = s !== 'connected';
    var pill = $('#findPc');
    if (pill) {
      pill.classList.toggle('ok', s === 'connected');
      pill.lastChild.nodeValue = s === 'connected' ? 'Connected to Desktop-PC' : 'Looking for PC on network...';
    }
  }

  /* ---------------- Timers ---------------- */
  var timers = {};
  function setT(key, fn, ms) { clearT(key); timers[key] = setTimeout(fn, ms); }
  function clearT(key) { if (timers[key]) { clearTimeout(timers[key]); timers[key] = null; } }

  function onEnter(name) {
    clearT('scan'); clearT('connect');
    if (name === 'scan') setT('scan', function () { setState('connecting'); }, 3000);
    if (name === 'connecting') setT('connect', function () { setState('connected'); }, 2800);
    if (name === 'transfer') startTransferTicker();
    else stopTransferTicker();
    if (name === 'screencast') stopShareTicker();
  }

  /* ---------------- Renderers ---------------- */
  function fileIcon(name) {
    var n = (name || '').toLowerCase();
    if (/\.(jpg|jpeg|png|gif|webp|heic)$/.test(n)) return 'image';
    if (/\.(mp4|mov|mkv|webm)$/.test(n)) return 'film';
    if (/\.(mp3|wav|m4a|flac)$/.test(n)) return 'music';
    if (/\.(zip|rar|7z|tar|gz)$/.test(n)) return 'drive';
    return 'file';
  }

  function renderRecent() {
    var host = $('#recentTransfers');
    host.innerHTML = DATA.recent.map(function (f) {
      var up = f.dir === 'up';
      var arrow = '<span class="icon-badge sm ' + (f.status === 'done' ? 'ok' : 'neutral') + '" data-icon="' + (up ? 'arrowUp' : 'arrowDown') + '"></span>';
      if (f.status === 'sending') {
        return '<div class="progress-row">' +
          '<div class="row gap-12">' +
            '<span class="file-glyph" data-icon="' + fileIcon(f.name) + '"></span>' +
            '<div class="grow"><div class="row between"><span class="bold truncate">' + esc(f.name) + '</span><span class="small bold">' + f.pct + '%</span></div>' +
            '<div class="meta">' + f.size + ' • Sending to Desktop-PC</div></div>' +
          '</div>' +
          '<div class="bar thin"><i style="width:' + f.pct + '%"></i></div>' +
          '<div class="row between tiny muted"><span>2.4 MB/s</span><span>3 seconds remaining</span></div>' +
        '</div>';
      }
      return '<div class="list-row">' +
        '<span class="file-glyph ok" data-icon="check"></span>' +
        '<div class="grow"><div class="bold truncate small">' + esc(f.name) + '</div>' +
        '<div class="meta">' + f.size + ' • ' + (up ? 'Sent to PC' : 'Received from PC') + '</div></div>' +
        arrow +
      '</div>';
    }).join('');
    U.hydrateIcons(host);
  }

  function renderQueue() {
    var host = $('#queueList');
    if (!DATA.queue.length) {
      host.innerHTML = '<div class="list-row muted small" style="justify-content:center">Queue is empty</div>';
    } else {
      host.innerHTML = DATA.queue.map(function (f, i) {
        return '<div class="list-row">' +
          '<span class="file-glyph" data-icon="' + fileIcon(f.name) + '"></span>' +
          '<div class="grow"><div class="bold truncate small">' + esc(f.name) + '</div>' +
          '<div class="meta">' + f.size + ' • ' + (f.dir === 'up' ? 'To Desktop-PC' : 'From Desktop-PC') + '</div></div>' +
          '<span class="badge badge-neutral">' + f.state + '</span>' +
          '<button class="iconbtn-dark" style="background:transparent;border:0;color:var(--muted);width:28px;height:28px" data-q-remove="' + i + '" aria-label="Remove"><span data-icon="x" data-size="15"></span></button>' +
        '</div>';
      }).join('');
      U.hydrateIcons(host);
    }
    var left = DATA.queue.length;
    $('#queueCount').textContent = '(' + left + ' file' + (left === 1 ? '' : 's') + ' remaining)';
  }

  function renderClipboard() {
    var host = $('#clipList');
    var tab = api.get('clipTab');
    var items = DATA.clipboard[tab];
    host.innerHTML = items.map(function (c) {
      var fromPc = tab === 'pc';
      return '<div class="clip-card">' +
        '<div class="clip-meta"><span class="src-dot ' + (fromPc ? 'pc' : '') + '"></span>' +
        '<span class="bold" style="color:var(--text)">' + (fromPc ? 'PC' : 'Phone') + '</span><span>•</span><span>' + esc(c.time) + '</span>' +
        '<span class="grow"></span><span class="icon-badge sm neutral" data-icon="' + c.glyph + '" style="width:24px;height:24px;border-radius:8px"></span></div>' +
        '<div class="clip-text' + (/^(https?:|SELECT|192\.)/.test(c.text) ? ' mono' : '') + '">' + esc(c.text) + '</div>' +
        '<div class="row gap-8">' +
          '<button class="btn btn-primary btn-sm" data-copy="' + (fromPc ? 'phone' : 'pc') + '" style="flex:1">' + (fromPc ? 'Paste on Phone' : 'Send to PC') + '</button>' +
          '<button class="btn btn-secondary btn-sm" data-clip-copy="' + esc(c.text) + '" data-icon="copy" data-size="15"></button>' +
        '</div>' +
      '</div>';
    }).join('');
    U.hydrateIcons(host);
  }

  function renderHistory() {
    var host = $('#historyList');
    host.innerHTML = DATA.history.map(function (h) {
      return '<div class="list-row">' +
        '<span class="icon-badge sm neutral" data-icon="laptop"></span>' +
        '<div class="grow"><div class="bold small">' + esc(h.name) + '</div><div class="meta">' + esc(h.meta) + '</div></div>' +
        (h.live ? '<span class="badge badge-ok"><span class="dot"></span>Active</span>'
                : '<button class="btn btn-secondary btn-sm" data-connect="' + esc(h.name) + '">Connect</button>') +
      '</div>';
    }).join('');
    U.hydrateIcons(host);
  }

  function renderSettings() {
    var host = $('#settingsGroups');
    host.innerHTML = DATA.settings.map(function (g) {
      var inner = g.demo ? demoCard() : '<div class="set-card">' + g.rows.map(function (r) { return rowHtml(r); }).join('') + '</div>';
      return '<div class="set-group"><div class="g-title">' + g.title + '</div>' + inner + '</div>';
    }).join('');
    U.hydrateIcons(host);
  }

  function rowHtml(r) {
    var right = '';
    if (r.type === 'switch') right = '<button class="switch" role="switch" aria-checked="' + (r.on ? 'true' : 'false') + '" aria-label="' + esc(r.label) + '"></button>';
    else if (r.type === 'link') right = '<span class="row gap-6"><span class="s-value">' + esc(r.value || '') + '</span><span class="faint" data-icon="chevronRight" data-size="16"></span></span>';
    else right = '<span class="s-value">' + esc(r.value || '') + '</span>';
    return '<div class="set-row"' + (r.type === 'link' ? ' data-rowlink="' + esc(r.label) + '" style="cursor:pointer"' : '') + '>' +
      '<div class="grow"><div class="s-label">' + esc(r.label) + '</div>' + (r.desc ? '<div class="s-desc">' + esc(r.desc) + '</div>' : '') + '</div>' +
      right + '</div>';
  }

  function demoCard() {
    var states = [
      ['disconnected', 'Disconnected'], ['connecting', 'Connecting'],
      ['connected', 'Connected'], ['error', 'Error']
    ];
    return '<div class="set-card"><div class="demo-grid">' + states.map(function (s) {
      return '<button class="btn btn-secondary btn-sm" data-state="' + s[0] + '">' + s[1] + '</button>';
    }).join('') + '</div>' +
      '<div class="row gap-8" style="padding:0 12px 12px"><button class="btn btn-soft btn-sm grow" data-action="reset">Reset demo data</button></div></div>';
  }

  /* ---------------- Transfer ticker ---------------- */
  var transferPct = 73, transferTimer = null;
  function startTransferTicker() {
    if (transferTimer) return;
    transferTimer = setInterval(function () {
      transferPct = Math.min(99, transferPct + 1);
      var pct = Math.round(transferPct);
      $('#tpPct').textContent = pct + '%';
      $('#tpBar').style.width = transferPct + '%';
      var meta = $('#s-transfer .progress-row .meta');
      if (meta) meta.textContent = '24.5 MB • ' + pct + '% Completed';
      var rem = Math.max(1, Math.round((100 - transferPct) * 0.11));
      $('#tpEta').textContent = rem + ' second' + (rem === 1 ? '' : 's') + ' remaining';
      $('#tpSpeed').textContent = (2.4 - (transferPct - 73) * 0.012).toFixed(1) + ' MB/s';
    }, 1400);
  }
  function stopTransferTicker() { if (transferTimer) { clearInterval(transferTimer); transferTimer = null; } }

  /* ---------------- Keyboard ---------------- */
  function renderKeys() {
    var v = $('#typeArea').value;
    var chars = v.slice(-14).split('');
    var strip = $('#keyStrip');
    if (!chars.length) chars = ['H', 'e', 'l', 'l', 'o', ' '];
    strip.innerHTML = chars.map(function (c) {
      var label = c === ' ' ? '␣' : (c === '\n' ? '↵' : esc(c));
      return '<span class="keycap hit">' + label + '</span>';
    }).join('') + (v ? '<span class="keycap" style="color:var(--accent);border-color:#F0CBBA">' + v.length + ' chars</span>' : '');
  }

  /* ---------------- Touchpad ---------------- */
  var pad, cursor, padRect, pointers = {}, downAt = 0, movedPx = 0, cx = 0, cy = 0;
  function setCursor(x, y) {
    cx = Math.max(24, Math.min(padRect.width - 24, x));
    cy = Math.max(24, Math.min(padRect.height - 24, y));
    cursor.style.left = cx + 'px';
    cursor.style.top = cy + 'px';
  }
  function ripple(x, y, right) {
    var r = document.createElement('span');
    r.className = 'tp-ripple' + (right ? ' right' : '');
    r.style.left = x + 'px'; r.style.top = y + 'px';
    pad.appendChild(r);
    setTimeout(function () { r.remove(); }, 560);
  }
  function gesture(txt) { $('#tpGesture').textContent = txt; }

  function initTouchpad() {
    pad = $('#touchpad'); cursor = $('#tpCursor');
    padRect = pad.getBoundingClientRect();
    setCursor(padRect.width / 2, padRect.height * 0.44);
    window.addEventListener('resize', function () { padRect = pad.getBoundingClientRect(); });

    pad.addEventListener('pointerdown', function (e) {
      pad.setPointerCapture(e.pointerId);
      pointers[e.pointerId] = { x: e.offsetX, y: e.offsetY };
      if (Object.keys(pointers).length === 1) { downAt = Date.now(); movedPx = 0; }
      gesture(Object.keys(pointers).length > 1 ? 'Scroll' : 'Move');
    });
    pad.addEventListener('pointermove', function (e) {
      var p = pointers[e.pointerId];
      if (!p) return;
      var dx = e.offsetX - p.x, dy = e.offsetY - p.y;
      p.x = e.offsetX; p.y = e.offsetY;
      movedPx += Math.abs(dx) + Math.abs(dy);
      var n = Object.keys(pointers).length;
      setCursor(cx + dx * (n > 1 ? 0.6 : 1.6), cy + dy * (n > 1 ? 0.6 : 1.6));
      if (n > 1) gesture('Scroll');
    });
    function up(e) {
      delete pointers[e.pointerId];
      if (Object.keys(pointers).length > 0) return;
      var tap = Date.now() - downAt < 260 && movedPx < 12;
      if (tap) {
        var two = !!e.twoFinger;
        ripple(cx, cy, two);
        gesture(two ? 'Right Click' : 'Left Click');
        U.toast(two ? 'Right click sent to PC' : 'Left click sent to PC');
      }
      gesture('Idle');
    }
    pad.addEventListener('pointerup', function (e) {
      e.twoFinger = Object.keys(pointers).length > 1;
      up(e);
    });
    pad.addEventListener('pointercancel', up);
  }

  /* ---------------- Screen share ---------------- */
  var shareTimer = null, shareSecs = 0, shareQuality = 'Balanced';
  function stopShareTicker() { if (shareTimer) { clearInterval(shareTimer); shareTimer = null; } }
  function startShareTicker() {
    stopShareTicker();
    shareTimer = setInterval(function () {
      shareSecs++;
      $('#ssElapsed').textContent = U.clock(shareSecs);
      var base = shareQuality === 'Low' ? 46 : shareQuality === 'High' ? 24 : 38;
      $('#ssLatency').textContent = (base + Math.round(Math.random() * 7 - 3)) + ' ms';
    }, 1000);
  }
  function applyQuality(q) {
    shareQuality = q;
    $$('#ssQuality button').forEach(function (b) { b.classList.toggle('active', b.getAttribute('data-q') === q); });
    var fps = q === 'Low' ? 15 : q === 'High' ? 60 : 30;
    $('#ssFps').textContent = fps + ' fps';
    U.toast('Stream quality set to ' + q);
  }
  function setSharing(on) {
    $('#ssIdle').hidden = on;
    $('#ssActive').hidden = !on;
    if (on) {
      shareSecs = 0;
      $('#ssElapsed').textContent = '00:00';
      applyQualitySilent(shareQuality);
      startShareTicker();
    } else {
      stopShareTicker();
    }
  }
  function applyQualitySilent(q) {
    var fps = q === 'Low' ? 15 : q === 'High' ? 60 : 30;
    $('#ssFps').textContent = fps + ' fps';
  }

  /* ---------------- Global interactions ---------------- */
  document.addEventListener('click', function (e) {
    var t = e.target;
    var goEl = t.closest('[data-go]');
    if (goEl) { go(goEl.getAttribute('data-go')); return; }

    var tabBtn = t.closest('.tabitem');
    if (tabBtn) { go(tabBtn.getAttribute('data-tab')); return; }

    var clipTab = t.closest('.tab');
    if (clipTab) {
      $$('#clipTabs .tab').forEach(function (b) { b.classList.remove('active'); });
      clipTab.classList.add('active');
      api.set({ clipTab: clipTab.getAttribute('data-clip') });
      renderClipboard();
      return;
    }

    var sw = t.closest('.switch');
    if (sw) {
      var on = sw.getAttribute('aria-checked') !== 'true';
      sw.setAttribute('aria-checked', on ? 'true' : 'false');
      var label = sw.getAttribute('aria-label') || 'Setting';
      U.toast(label + (on ? ' enabled' : ' disabled'));
      return;
    }

    var st = t.closest('[data-state]');
    if (st) { setState(st.getAttribute('data-state'), true); return; }

    var rm = t.closest('[data-q-remove]');
    if (rm) {
      DATA.queue.splice(Number(rm.getAttribute('data-q-remove')), 1);
      renderQueue();
      U.toast('Removed from queue');
      return;
    }

    var cp = t.closest('[data-copy]');
    if (cp) { U.toast(cp.getAttribute('data-copy') === 'pc' ? 'Text sent to PC clipboard' : 'Text pasted on Phone'); return; }

    var cc = t.closest('[data-clip-copy]');
    if (cc) { U.toast('Copied to clipboard'); return; }

    var cn = t.closest('[data-connect]');
    if (cn) { setState('connecting'); return; }

    var cl = t.closest('[data-click]');
    if (cl) {
      var right = cl.getAttribute('data-click') === 'right';
      ripple(cx, cy, right);
      gesture(right ? 'Right Click' : 'Left Click');
      U.toast(right ? 'Right click sent to PC' : 'Left click sent to PC');
      return;
    }

    var rl = t.closest('[data-rowlink]');
    if (rl) { U.toast(rl.getAttribute('data-rowlink') + ' — prototype only'); return; }

    var act = t.closest('[data-action]');
    if (act) { resetDemo(); return; }

    var q = t.closest('#ssQuality button');
    if (q) { applyQuality(q.getAttribute('data-q')); return; }
  });

  function resetDemo() {
    DATA.queue = [
      { name: 'budget-q3.xlsx', size: '1.2 MB', dir: 'up', state: 'Waiting' },
      { name: 'screenshot-2026.png', size: '860 KB', dir: 'up', state: 'Waiting' }
    ];
    transferPct = 73;
    renderQueue(); renderRecent();
    U.toast('Demo data reset');
  }

  /* ---------------- Screen specific wiring ---------------- */
  U.on($('#btnIpConnect'), 'click', function () {
    var ip = ($('#ipInput').value || '').trim() || '192.168.1.42';
    if (!/^\d{1,3}(\.\d{1,3}){3}$/.test(ip)) { U.toast('Enter a valid local IP address'); return; }
    U.toast('Contacting ' + ip + '…');
    setState('connecting');
  });
  U.on($('#ipInput'), 'keydown', function (e) { if (e.key === 'Enter') $('#btnIpConnect').click(); });

  U.on($('#btnStop'), 'click', function () { setState('disconnected'); U.toast('Disconnected from Desktop-PC'); });
  U.on($('#btnDisconnectDevice'), 'click', function () { setState('disconnected'); U.toast('Device disconnected'); });
  U.on($('#btnCancelTransfer'), 'click', function () { go('files'); U.toast('Transfer cancelled'); });
  U.on($('#btnClearQueue'), 'click', function () {
    if (!DATA.queue.length) { U.toast('Queue is already empty'); return; }
    DATA.queue = []; renderQueue(); U.toast('Queue cleared');
  });
  U.on($('#dropZone'), 'click', function () { U.toast('3 files selected • 14.2 MB'); setTimeout(function () { go('transfer'); }, 350); });

  U.on($('#typeArea'), 'input', renderKeys);
  U.on($('#btnActivateTyping'), 'click', function () {
    $('#typeArea').focus();
    U.toast('Remote typing active on Desktop-PC');
  });
  U.on($('#btnClearText'), 'click', function () { $('#typeArea').value = ''; renderKeys(); U.toast('Text cleared'); });

  U.on($('#ringVol'), 'input', function () {
    $('#ringVolLabel').textContent = this.value + '%';
  });
  var ringing = true;
  U.on($('#btnStopAlert'), 'click', function () {
    ringing = !ringing;
    $$('.ring-wave').forEach(function (w) { w.style.animationPlayState = ringing ? 'running' : 'paused'; w.style.opacity = ringing ? '1' : '0'; });
    $('#ringCore').classList.toggle('idle', !ringing);
    $('#ringStatus').textContent = ringing ? 'Playing a loud alert sound on Desktop-PC' : 'Alert stopped on Desktop-PC';
    this.innerHTML = ringing ? U.icon('stop', 18) + 'Stop Alert' : U.icon('bell', 18) + 'Ring Again';
    U.toast(ringing ? 'Ringing Desktop-PC at full volume' : 'Alert stopped');
  });

  U.on($('#btnStartShare'), 'click', function () { $('#permModal').classList.add('show'); });
  U.on($('#permCancel'), 'click', function () { $('#permModal').classList.remove('show'); U.toast('Screen capture permission denied'); });
  U.on($('#permStart'), 'click', function () {
    $('#permModal').classList.remove('show');
    setSharing(true);
    U.toast('Screen share started · local only');
  });
  U.on($('#btnStopShare'), 'click', function () { setSharing(false); U.toast('Screen share stopped'); });

  /* ---------------- postMessage bridge ---------------- */
  U.bridge(api, {
    onSetState: function (status) { setState(status, true); },
    onNav: function (screen) { go(screen); },
    onAction: function (action) {
      if (action === 'reset') resetDemo();
      if (action === 'share') setSharing(true);
      if (action === 'stopshare') setSharing(false);
    },
    screen: currentScreen,
    label: function () { return api.get('status'); }
  });

  /* ---------------- Boot ---------------- */
  U.hydrateIcons();
  renderRecent(); renderQueue(); renderClipboard(); renderHistory(); renderSettings();
  initTouchpad(); renderKeys(); syncChrome();
  go('home');
})();
