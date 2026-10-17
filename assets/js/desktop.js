/* ============================================================
   Link — Desktop mockup behaviour
   ============================================================ */
(function () {
  'use strict';
  var U = window.LinkUI;
  var $ = U.$, $$ = U.$$, esc = U.esc;

  document.body.classList.toggle('in-frame', window.self !== window.top);
  U.fit($('#win'), 1100, 700);

  /* ---------------- Mock data ---------------- */
  var DATA = {
    phoneFiles: [
      { n: 'holiday-photo.jpg', m: '4.8 MB · Today 14:31', i: 'image' },
      { n: 'presentation.pdf', m: '24.5 MB · Today 14:02', i: 'file' },
      { n: 'budget-q3.xlsx', m: '1.2 MB · Yesterday', i: 'file' },
      { n: 'voice-note.m4a', m: '2.1 MB · Yesterday', i: 'music' },
      { n: 'screenshot-2026.png', m: '860 KB · Monday', i: 'image' }
    ],
    computerFiles: [
      { n: 'link-setup.exe', m: '18.2 MB · Installer', i: 'download' },
      { n: 'project-assets.zip', m: '128 MB · Folder archive', i: 'drive' },
      { n: 'family-video.mp4', m: '240 MB · Videos', i: 'film' },
      { n: 'notes.txt', m: '12 KB · Documents', i: 'file' },
      { n: 'screenshots', m: '12 items · Pictures', i: 'image' }
    ],
    transfers: [
      { n: 'presentation.pdf', s: '24.5 MB', pct: 73, to: 'phone', state: 'sending' },
      { n: 'holiday-photo.jpg', s: '4.8 MB', pct: 100, to: 'pc', state: 'done' },
      { n: 'project-assets.zip', s: '128 MB', pct: 100, to: 'phone', state: 'done' }
    ],
    done: [
      { n: 'presentation.pdf', s: '24.5 MB' },
      { n: 'budget-q3.xlsx', s: '1.2 MB' },
      { n: 'screenshot-2026.png', s: '860 KB' }
    ],
    phoneClip: [
      { t: 'Just now', x: 'Meet me at the library at 6pm — the one next to the park.' },
      { t: '12 min ago', x: '192.168.1.42' },
      { t: '1 hour ago', x: 'Holiday packing list: passport, charger, adapter, headphones, sunglasses.' }
    ],
    pcClip: [
      { t: 'Just now', x: 'https://docs.local/link-offline-first-notes' },
      { t: '26 min ago', x: 'SELECT * FROM transfers WHERE device = "pixel-8-pro";' },
      { t: '2 hours ago', x: 'Sprint review moved to Thursday 10:30 — room Ada.' }
    ],
    devices: [
      { n: 'Pixel 8 Pro', m: '192.168.1.42 · 340 Mbps · 1.4 GB transferred', primary: true },
      { n: 'Galaxy S23', m: '192.168.1.57 · 210 Mbps · 96 MB transferred', primary: false }
    ],
    settings: [
      { title: 'General', icon: 'sliders', rows: [
        { label: 'Language', type: 'select', value: 'English (US)', options: ['English (US)', 'Français', 'Español', 'Deutsch'] },
        { label: 'Start on Boot', desc: 'Launch Link when Windows starts', type: 'switch', on: true },
        { label: 'Notifications', desc: 'Show transfer and connection alerts', type: 'switch', on: true },
        { label: 'Minimize to tray', desc: 'Keep running in the background', type: 'switch', on: true }
      ] },
      { title: 'Connection', icon: 'wifi', rows: [
        { label: 'Port', desc: 'Local listening port', type: 'value', value: '8080' },
        { label: 'Auto-connect', desc: 'Reconnect known phones automatically', type: 'switch', on: true },
        { label: 'Timeout', desc: 'Time before giving up on pairing', type: 'value', value: '30 seconds' },
        { label: 'Wi-Fi network', desc: 'Detected local interface', type: 'value', value: 'HomeNet-5G' }
      ] },
      { title: 'Security', icon: 'shield', rows: [
        { label: 'Require PIN for pairing', desc: 'Ask for the 4-digit code shown on both devices', type: 'switch', on: true },
        { label: 'Local TLS Encryption', desc: 'Encrypt all traffic on the local channel', type: 'switch', on: true },
        { label: 'Allowed Devices', desc: 'Phones allowed to reconnect without confirmation', type: 'value', value: '2 devices' }
      ] },
      { title: 'About', icon: 'info', rows: [
        { label: 'Version', desc: 'Link for Windows', type: 'value', value: '1.0.0 Stable' },
        { label: 'Check for updates', desc: 'Requires internet only for the installer', type: 'link', value: 'Check Now' },
        { label: 'Open-source licences', desc: 'MIT · Adwaita icons', type: 'link', value: 'View' }
      ] }
    ]
  };

  /* ---------------- Store + navigation ---------------- */
  var api = U.store({ status: 'disconnected', screen: 'overview', ss: 'idle' });

  var CRUMB = {
    overview: 'Overview', files: 'Files', transferComplete: 'File Transfer',
    clipboard: 'Clipboard', keyboard: 'Remote Keyboard', mouse: 'Remote Touchpad',
    screen: 'Screen Share', ring: 'Ring Phone', settings: 'Settings'
  };
  var SIDE = { transferComplete: 'files' };

  function go(name) {
    if (!CRUMB[name]) name = 'overview';
    $$('.d-screen').forEach(function (s) { s.classList.remove('active'); });
    var el = document.getElementById('d-' + name);
    if (el) el.classList.add('active');
    var side = SIDE[name] || name;
    $$('.nav-item').forEach(function (b) { b.classList.toggle('active', b.getAttribute('data-dscreen') === side); });
    $('#tbCrumb').textContent = CRUMB[name];
    $('#win').setAttribute('data-screen', name);
    $('#mainScroll').scrollTop = 0;
    api.set({ screen: name });
  }

  function setState(status) { api.set({ status: status }); }
  function setSS(state) { $('#d-screen').setAttribute('data-ss', state); api.set({ ss: state }); }

  api.sub(function (state, patch) {
    if ('status' in patch) applyStatus(state.status);
  });

  function applyStatus(status) {
    var win = $('#win');
    win.setAttribute('data-status', status);
    var label = $('#tbDeviceText');
    if (status === 'connected') label.textContent = 'Pixel 8 Pro';
    else if (status === 'connecting') label.textContent = 'Pairing…';
    else if (status === 'error') label.textContent = 'Pairing failed';
    else label.textContent = 'Offline Mode';
    if (status === 'connecting') setT('conn', function () { setState('connected'); }, 2600);
    else clearT('conn');
  }

  /* ---------------- QR code (deterministic placeholder) ---------------- */
  function renderQR() {
    var N = 29, seed = 20261017, cells = [], i;
    function rnd() { seed = (seed * 1103515245 + 12345) & 0x7fffffff; return seed / 0x7fffffff; }
    function finderZone(x, y) { return (x < 8 && y < 8) || (x > N - 9 && y < 8) || (x < 8 && y > N - 9); }
    function centre(x, y) { return x > 11 && x < 17 && y > 11 && y < 17; }
    for (var y = 0; y < N; y++) {
      for (var x = 0; x < N; x++) {
        if (finderZone(x, y) || centre(x, y)) continue;
        if (rnd() > 0.52) cells.push('<rect x="' + x + '" y="' + y + '" width="1" height="1"/>');
      }
    }
    function finder(ox, oy) {
      return '<rect x="' + ox + '" y="' + oy + '" width="7" height="7"/>' +
        '<rect x="' + (ox + 1) + '" y="' + (oy + 1) + '" width="5" height="5" fill="#fff"/>' +
        '<rect x="' + (ox + 2) + '" y="' + (oy + 2) + '" width="3" height="3"/>';
    }
    $('#qrSvg').innerHTML = '<g fill="#2A2420">' + cells.join('') + finder(0, 0) + finder(N - 7, 0) + finder(0, N - 7) + '</g>' +
      '<rect x="11.4" y="11.4" width="6.2" height="6.2" rx="1.7" fill="#DD5B35"/>' +
      '<circle cx="13.3" cy="14.5" r="1.35" fill="none" stroke="#fff" stroke-width=".75"/>' +
      '<circle cx="15.7" cy="14.5" r="1.35" fill="none" stroke="#fff" stroke-width=".75"/>';
  }

  /* ---------------- Renderers ---------------- */
  function fileRow(f) {
    return '<div class="file-item"><span class="file-glyph" data-icon="' + f.i + '"></span>' +
      '<div class="grow"><div class="fi-name truncate">' + esc(f.n) + '</div><div class="fi-meta">' + esc(f.m) + '</div></div>' +
      '<span class="faint" data-icon="chevronRight" data-size="16"></span></div>';
  }

  function renderFiles() {
    $('#phoneFiles').innerHTML = DATA.phoneFiles.map(fileRow).join('');
    $('#computerFiles').innerHTML = DATA.computerFiles.map(fileRow).join('');
    U.hydrateIcons($('#phoneFiles')); U.hydrateIcons($('#computerFiles'));
  }

  function renderTransfers() {
    $('#desktopTransfers').innerHTML = DATA.transfers.map(function (t) {
      var dir = t.to === 'phone' ? 'Computer → Phone' : 'Phone → Computer';
      if (t.state === 'sending') {
        return '<div class="transfer-line">' +
          '<div class="row gap-12"><span class="file-glyph" data-icon="file"></span>' +
          '<div class="grow"><div class="row between"><span class="bold small">' + esc(t.n) + '</span><span class="small bold" data-tp="' + esc(t.n) + '">' + t.pct + '%</span></div>' +
          '<div class="meta muted small">' + t.s + ' • ' + dir + '</div></div></div>' +
          '<div class="bar thin"><i data-tpbar style="width:' + t.pct + '%"></i></div>' +
          '<div class="row between tiny muted"><span>2.4 MB/s</span><span>3 seconds remaining</span></div></div>';
      }
      return '<div class="transfer-line" style="gap:7px">' +
        '<div class="row gap-12"><span class="file-glyph ok" data-icon="check"></span>' +
        '<div class="grow"><div class="bold small">' + esc(t.n) + '</div><div class="meta muted small">' + t.s + ' • ' + dir + '</div></div>' +
        '<span class="badge badge-ok"><span class="dot"></span>Complete</span></div></div>';
    }).join('');
    U.hydrateIcons($('#desktopTransfers'));
  }

  function renderDone() {
    $('#doneList').innerHTML = DATA.done.map(function (f) {
      return '<div class="list-row"><span class="file-glyph ok" data-icon="check"></span>' +
        '<div class="grow"><div class="bold small">' + esc(f.n) + '</div><div class="meta">' + f.s + ' • Sent to Pixel 8 Pro</div></div>' +
        '<span class="badge badge-ok"><span class="dot"></span>Saved</span></div>';
    }).join('');
    U.hydrateIcons($('#doneList'));
  }

  function clipCard(c, target) {
    var mono = /^(https?:|SELECT|192\.)/.test(c.x);
    return '<div class="clip-item">' +
      '<div class="row gap-8 tiny muted"><span class="src-dot' + (target === 'pc' ? ' pc' : '') + '"></span>' +
      '<span class="bold" style="color:var(--text)">' + (target === 'pc' ? 'PC' : 'Phone') + '</span><span>•</span><span>' + esc(c.t) + '</span></div>' +
      '<div class="txt' + (mono ? ' mono' : '') + '">' + esc(c.x) + '</div>' +
      '<div class="foot"><button class="btn btn-primary btn-sm" data-clip="' + (target === 'pc' ? 'phone' : 'pc') + '">' +
      (target === 'pc' ? 'Copy to Phone' : 'Copy to PC') + '</button>' +
      '<button class="btn btn-secondary btn-sm" data-copy-text="' + esc(c.x) + '" data-icon="copy" data-size="15"></button></div></div>';
  }

  function renderClipboard() {
    $('#pcClipboardList').innerHTML = DATA.phoneClip.map(function (c) { return clipCard(c, 'phone'); }).join('');
    $('#deskClipboardList').innerHTML = DATA.pcClip.map(function (c) { return clipCard(c, 'pc'); }).join('');
    U.hydrateIcons($('#pcClipboardList')); U.hydrateIcons($('#deskClipboardList'));
  }

  function renderDevices() {
    $('#desktopDevices').innerHTML = DATA.devices.map(function (d, i) {
      return '<div class="device-row"><span class="icon-badge lg" data-icon="phone"></span>' +
        '<div class="grow"><div class="row gap-8"><span class="bold">' + esc(d.n) + '</span>' +
        (d.primary ? '<span class="badge badge-ok"><span class="dot"></span>Active</span>' : '<span class="badge badge-accent"><span class="dot"></span>Connected</span>') + '</div>' +
        '<div class="meta mono">' + esc(d.m) + '</div></div>' +
        '<button class="btn btn-soft-danger btn-sm" data-disconnect="' + i + '">Disconnect</button></div>';
    }).join('');
    U.hydrateIcons($('#desktopDevices'));
  }

  function renderSettings() {
    var panels = DATA.settings.map(function (g) {
      return '<div class="set-panel"><div class="sp-head"><span class="icon-badge sm" data-icon="' + g.icon + '"></span>' +
        '<div class="sp-title">' + g.title + '</div></div><div class="sp-body">' +
        g.rows.map(function (r) {
          var right;
          if (r.type === 'switch') right = '<button class="switch" role="switch" aria-checked="' + (r.on ? 'true' : 'false') + '" aria-label="' + esc(r.label) + '"></button>';
          else if (r.type === 'select') right = '<select class="select" aria-label="' + esc(r.label) + '">' + r.options.map(function (o) { return '<option' + (o === r.value ? ' selected' : '') + '>' + esc(o) + '</option>'; }).join('') + '</select>';
          else if (r.type === 'link') right = '<span class="row gap-6"><button class="link">' + esc(r.value) + '</button><span class="faint" data-icon="chevronRight" data-size="15"></span></span>';
          else right = '<span class="l-value">' + esc(r.value) + '</span>';
          return '<div class="set-line"><div class="grow"><div class="l-label">' + esc(r.label) + '</div>' +
            (r.desc ? '<div class="l-desc">' + esc(r.desc) + '</div>' : '') + '</div>' + right + '</div>';
        }).join('') + '</div></div>';
    }).join('');

    var states = [['disconnected', 'Ready to Connect'], ['connecting', 'Connecting'], ['connected', 'Connected'], ['error', 'Connection Failed']];
    var proto = '<div class="set-panel" style="grid-column:1/-1"><div class="sp-head"><span class="icon-badge sm" data-icon="sparkle"></span>' +
      '<div class="sp-title">Prototype</div><span class="badge badge-accent" style="margin-left:auto"><span class="dot"></span>Mockup</span></div>' +
      '<div class="sp-body"><div class="set-line"><div class="grow"><div class="l-label">Connection state</div>' +
      '<div class="l-desc">Switch the whole window between the simulated states</div></div>' +
      '<div class="row gap-8 wrap" style="justify-content:flex-end">' +
      states.map(function (s) { return '<button class="btn btn-secondary btn-sm" data-state="' + s[0] + '">' + s[1] + '</button>'; }).join('') + '</div></div>' +
      '<div class="set-line"><div class="grow"><div class="l-label">Screen share state</div>' +
      '<div class="l-desc">Waiting, live stream or interrupted stream</div></div>' +
      '<div class="row gap-8" style="justify-content:flex-end">' +
      '<button class="btn btn-secondary btn-sm" data-ss-state="idle">Waiting</button>' +
      '<button class="btn btn-secondary btn-sm" data-ss-state="live">Live</button>' +
      '<button class="btn btn-secondary btn-sm" data-ss-state="error">Interrupted</button></div></div>' +
      '<div class="set-line"><div class="grow"><div class="l-label">Reset demo</div>' +
      '<div class="l-desc">Restore transfers, clipboard and states</div></div>' +
      '<button class="btn btn-soft btn-sm" data-action="reset">Reset demo data</button></div></div></div>';

    $('#deskSettings').innerHTML = panels + proto;
    U.hydrateIcons($('#deskSettings'));
  }

  /* ---------------- Timers ---------------- */
  var timers = {};
  function setT(k, fn, ms) { clearT(k); timers[k] = setTimeout(fn, ms); }
  function clearT(k) { if (timers[k]) { clearTimeout(timers[k]); timers[k] = null; } }

  var tpPct = 73, tpTimer = null;
  function startTp() {
    if (tpTimer) return;
    tpTimer = setInterval(function () {
      tpPct = Math.min(99, tpPct + 1);
      $$('[data-tp]').forEach(function (el) { el.textContent = Math.round(tpPct) + '%'; });
      $$('[data-tpbar]').forEach(function (el) { el.style.width = tpPct + '%'; });
    }, 1500);
  }

  var ssTimer = null, ssSecs = 0;
  function startSSTicker() {
    stopSSTicker();
    ssTimer = setInterval(function () {
      ssSecs++;
      var el = $('#ssElapsed'); if (el) el.textContent = U.clock(ssSecs);
      var lat = $('#ssLatency');
      if (lat) lat.textContent = (36 + Math.round(Math.random() * 8)) + ' ms';
    }, 1000);
  }
  function stopSSTicker() { if (ssTimer) { clearInterval(ssTimer); ssTimer = null; } }
  function setQuality(q) {
    $$('#ssQuality button').forEach(function (b) { b.classList.toggle('active', b.getAttribute('data-q') === q); });
    var map = { Low: ['480p', '15 fps', '2.1 Mbps'], Balanced: ['1080p', '30 fps', '6.2 Mbps'], High: ['1080p', '60 fps', '12.4 Mbps'] };
    var v = map[q] || map.Balanced;
    $('#ssRes').textContent = v[0]; $('#ssFps').textContent = v[1]; $('#ssBitrate').textContent = v[2];
    U.toast('Stream quality set to ' + q);
  }

  /* ---------------- Keyboard receiver ---------------- */
  var kbTimer = null, kbText = 'Hello from Pixel 8 Pro — the local network is fast.', kbIndex = 0, kbOn = false;
  function toggleKeyboardReceiver(on) {
    kbOn = on;
    var badge = $('#kbState');
    if (on) {
      badge.className = 'badge badge-ok'; badge.innerHTML = '<span class="dot"></span>Receiving live input';
      kbIndex = 0; $('#kbPreview').textContent = ''; $('#kbPreview').classList.remove('muted');
      clearInterval(kbTimer);
      kbTimer = setInterval(function () {
        if (kbIndex >= kbText.length) { clearInterval(kbTimer); return; }
        $('#kbPreview').textContent += kbText.charAt(kbIndex++);
      }, 55);
      $('#btnKeyboardReceiver').innerHTML = U.icon('stop', 17) + 'Stop Receiver';
      U.toast('Keyboard receiver started on port 8080');
    } else {
      clearInterval(kbTimer);
      badge.className = 'badge badge-warn'; badge.innerHTML = '<span class="dot"></span>Waiting for receiver';
      $('#btnKeyboardReceiver').innerHTML = U.icon('play', 17) + 'Start Keyboard Receiver';
      U.toast('Keyboard receiver stopped');
    }
  }

  /* ---------------- Global interactions ---------------- */
  document.addEventListener('click', function (e) {
    var t = e.target;

    var st = t.closest('[data-state]');
    if (st) { setState(st.getAttribute('data-state')); go('overview'); return; }

    var ssState = t.closest('[data-ss-state]');
    if (ssState) { applySS(ssState.getAttribute('data-ss-state')); go('screen'); return; }

    var disc = t.closest('[data-disconnect]');
    if (disc) {
      var i = Number(disc.getAttribute('data-disconnect'));
      var d = DATA.devices[i];
      DATA.devices.splice(i, 1);
      renderDevices();
      U.toast((d ? d.n : 'Device') + ' disconnected');
      return;
    }

    var act = t.closest('[data-action]');
    if (act) { handleAction(act.getAttribute('data-action')); return; }

    var nav = t.closest('[data-dscreen]');
    if (nav) { go(nav.getAttribute('data-dscreen')); return; }

    var clip = t.closest('[data-clip]');
    if (clip) { U.toast(clip.getAttribute('data-clip') === 'phone' ? 'Copied to Pixel 8 Pro clipboard' : 'Copied to this computer clipboard'); return; }

    var ct = t.closest('[data-copy-text]');
    if (ct) { U.toast('Copied to clipboard'); return; }

    var q = t.closest('#ssQuality button');
    if (q) { setQuality(q.getAttribute('data-q')); return; }

    var sw = t.closest('.switch');
    if (sw) {
      var on = sw.getAttribute('aria-checked') !== 'true';
      sw.setAttribute('aria-checked', on ? 'true' : 'false');
      U.toast((sw.getAttribute('aria-label') || 'Setting') + (on ? ' enabled' : ' disabled'));
      return;
    }
  });

  function handleAction(a) {
    switch (a) {
      case 'cancel': setState('disconnected'); go('overview'); U.toast('Pairing cancelled'); break;
      case 'retry': setState('connecting'); go('overview'); break;
      case 'troubleshoot': U.toast('Diagnostics: check firewall on port 8080'); break;
      case 'ip-manual': U.toast('Enter 192.168.1.42 manually on your phone'); break;
      case 'ss-live': applySS('live'); go('screen'); U.toast('Incoming screen stream from Pixel 8 Pro'); break;
      case 'ss-error': applySS('error'); U.toast('Screen share interrupted — reconnecting'); break;
      case 'ss-stop': applySS('idle'); U.toast('Screen share stopped'); break;
      case 'ss-fullscreen': U.toast('Live view expanded to fullscreen'); break;
      case 'ss-screenshot': U.toast('Screenshot saved to Pictures\\Link'); break;
      case 'desk-rightclick': U.toast('Right click sent to Pixel 8 Pro'); break;
      case 'clear-transfers': DATA.transfers = []; renderTransfers(); U.toast('Transfer history cleared'); break;
      case 'reset': resetDemo(); break;
      default: U.toast('Prototype action: ' + a);
    }
  }

  function applySS(state) {
    setSS(state);
    if (state === 'live') { ssSecs = 0; var el = $('#ssElapsed'); if (el) el.textContent = '00:00'; startSSTicker(); }
    else stopSSTicker();
  }

  function resetDemo() {
    DATA.transfers = [
      { n: 'presentation.pdf', s: '24.5 MB', pct: 73, to: 'phone', state: 'sending' },
      { n: 'holiday-photo.jpg', s: '4.8 MB', pct: 100, to: 'pc', state: 'done' },
      { n: 'project-assets.zip', s: '128 MB', pct: 100, to: 'phone', state: 'done' }
    ];
    DATA.devices = [
      { n: 'Pixel 8 Pro', m: '192.168.1.42 · 340 Mbps · 1.4 GB transferred', primary: true },
      { n: 'Galaxy S23', m: '192.168.1.57 · 210 Mbps · 96 MB transferred', primary: false }
    ];
    tpPct = 73;
    renderTransfers(); renderDevices(); renderClipboard();
    setState('disconnected'); applySS('idle');
    U.toast('Demo data reset');
  }

  /* ---------------- Screen specific wiring ---------------- */
  U.on($('#btnCopyIp'), 'click', function () { U.toast('Local IP 192.168.1.42 copied'); });
  U.on($('#btnDisconnect'), 'click', function () {
    setState('disconnected'); go('overview');
    U.toast('All devices disconnected');
  });
  U.on($('#btnSendFiles'), 'click', function () {
    U.toast('Sending 3 files • 14.2 MB');
    setT('send', function () { go('transferComplete'); }, 1500);
  });
  U.on($('#dropZone'), 'click', function () {
    this.classList.add('over');
    U.toast('3 files selected • 14.2 MB');
    var self = this;
    setTimeout(function () { self.classList.remove('over'); go('transferComplete'); }, 700);
  });
  U.on($('#btnKeyboardReceiver'), 'click', function () { toggleKeyboardReceiver(!kbOn); });
  U.on($('#btnKeyboardClear'), 'click', function () {
    clearInterval(kbTimer); kbIndex = 0;
    $('#kbPreview').textContent = ''; $('#kbPreview').classList.add('muted');
    U.toast('Text cleared');
  });
  U.on($('#btnStartMouse'), 'click', function () {
    U.toast('Mouse control active — Pixel 8 Pro is the trackpad');
    var cur = $('#deskCursor'), zone = $('#deskTrackpad');
    var r = zone.getBoundingClientRect();
    cur.style.left = (30 + Math.random() * (r.width - 60)) + 'px';
    cur.style.top = (26 + Math.random() * (r.height - 52)) + 'px';
  });

  var deskRinging = false;
  function deskRing(on) {
    deskRinging = on;
    $('#deskRingBig').classList.toggle('waves', on);
    $('#deskRingTitle').textContent = on ? 'Ringing Pixel 8 Pro' : 'Ready to ring';
    $('#deskRingStatus').textContent = on
      ? 'Playing a loud alert sound on Pixel 8 Pro at ' + $('#deskRingVol').value + '% volume — silent mode bypassed.'
      : 'Press the button below to play the alert on Pixel 8 Pro.';
    U.toast(on ? 'Ringing Pixel 8 Pro at full volume' : 'Ringing stopped');
  }
  U.on($('#btnRingPhone'), 'click', function () { deskRing(true); });
  U.on($('#btnStopRinging'), 'click', function () { deskRing(false); });
  U.on($('#deskRingVol'), 'input', function () {
    $('#deskRingVolLabel').textContent = this.value + '%';
    if (deskRinging) $('#deskRingStatus').textContent = 'Playing a loud alert sound on Pixel 8 Pro at ' + this.value + '% volume — silent mode bypassed.';
  });

  /* ---------------- postMessage bridge ---------------- */
  U.bridge(api, {
    onSetState: function (status) { setState(status); go('overview'); },
    onNav: function (screen) { go(screen); },
    onAction: function (action) {
      if (action === 'ss:live') applySS('live');
      else if (action === 'ss:idle') applySS('idle');
      else if (action === 'ss:error') applySS('error');
      else handleAction(action);
    },
    screen: function () { return api.get('screen'); },
    label: function () { return api.get('status'); }
  });

  /* ---------------- Boot ---------------- */
  U.hydrateIcons();
  renderQR(); renderFiles(); renderTransfers(); renderDone(); renderClipboard(); renderDevices(); renderSettings();
  applyStatus('disconnected');
  startTp();
  go('overview');
})();
