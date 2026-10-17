/* ============================================================
   Link — shared UI runtime: icon set, tiny store, helpers,
   toast, standalone shell fitting and postMessage bridge.
   ============================================================ */
(function (global) {
  'use strict';

  /* ---------------- Icon set (inline, no dependencies) ---------------- */
  var ICONS = {
    home:'<path d="M3 10.6 12 3.4l9 7.2"/><path d="M5.5 9.4V20a.9.9 0 0 0 .9.9h11.2a.9.9 0 0 0 .9-.9V9.4"/>',
    folder:'<path d="M3 7.6A2 2 0 0 1 5 5.6h3.6l2 2.2H19a2 2 0 0 1 2 2v8.2a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
    clipboard:'<rect x="8.8" y="3" width="6.4" height="3.8" rx="1.2"/><path d="M15.2 4.9H17a2 2 0 0 1 2 2V19a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6.9a2 2 0 0 1 2-2h1.8"/>',
    grid:'<rect x="3.5" y="3.5" width="7" height="7" rx="2"/><rect x="13.5" y="3.5" width="7" height="7" rx="2"/><rect x="3.5" y="13.5" width="7" height="7" rx="2"/><rect x="13.5" y="13.5" width="7" height="7" rx="2"/>',
    gear:'<circle cx="12" cy="12" r="3.1"/><path d="M12 2.8v2.1M12 19.1v2.1M4.5 4.5l1.5 1.5M18 18l1.5 1.5M2.8 12h2.1M19.1 12h2.1M4.5 19.5 6 18M18 6l1.5-1.5"/><circle cx="12" cy="12" r="8.4" stroke-dasharray="2.4 3.2"/>',
    monitor:'<rect x="2.5" y="4" width="19" height="13" rx="2.2"/><path d="M8.6 21h6.8M12 17v4"/>',
    keyboard:'<rect x="2.5" y="6" width="19" height="12" rx="2.4"/><path d="M6.2 10h.01M9.6 10h.01M13 10h.01M16.4 10h.01M6.2 13.6h.01M17.8 13.6h.01M8.6 14.2h6.8"/>',
    pointer:'<path d="M6 3.6 19 11.2l-6.1 1.5L10.6 19z"/>',
    bell:'<path d="M18 8.6a6 6 0 1 0-12 0c0 6-2.4 7.4-2.4 7.4h16.8S18 14.6 18 8.6"/><path d="M13.7 19.6a2 2 0 0 1-3.4 0"/>',
    cast:'<rect x="2.5" y="4.5" width="12.5" height="9.5" rx="2"/><path d="M7.5 20h6"/><rect x="15.6" y="8.5" width="5.9" height="11" rx="1.8"/><path d="M18.2 17.2h.01"/>',
    link:'<path d="M10.2 13.6a4 4 0 0 0 5.6 0l2.7-2.7a4 4 0 0 0-5.7-5.7l-1.3 1.3"/><path d="M13.8 10.4a4 4 0 0 0-5.6 0l-2.7 2.7a4 4 0 0 0 5.7 5.7l1.3-1.3"/>',
    unlink:'<path d="M10.4 13.6 8.1 15.9a3.4 3.4 0 0 1-4.8-4.8l2.3-2.3"/><path d="M13.6 10.4l2.3-2.3a3.4 3.4 0 0 1 4.8 4.8l-2.3 2.3"/><path d="M3.6 3.6l16.8 16.8"/>',
    wifi:'<path d="M2.2 9.2a15 15 0 0 1 19.6 0"/><path d="M5.6 12.6a10 10 0 0 1 12.8 0"/><path d="M8.8 15.9a5.4 5.4 0 0 1 6.4 0"/><path d="M12 19.3h.01"/>',
    qr:'<rect x="3" y="3" width="7" height="7" rx="1.8"/><rect x="14" y="3" width="7" height="7" rx="1.8"/><rect x="3" y="14" width="7" height="7" rx="1.8"/><path d="M14 14h3.2v3.2H14zM20.4 14h.6M14 20.4h.6M18 18h3v3h-3z"/>',
    alert:'<path d="M12 3.6 21 19.4a1 1 0 0 1-.9 1.5H3.9a1 1 0 0 1-.9-1.5z"/><path d="M12 9.4v4.3M12 17h.01"/>',
    check:'<path d="M4.6 12.8 9.6 17.5 19.4 7"/>',
    checkCircle:'<circle cx="12" cy="12" r="9"/><path d="M8 12.3 11 15.2 16 9.8"/>',
    arrowUp:'<path d="M12 19.5V5M6 11l6-6 6 6"/>',
    arrowDown:'<path d="M12 4.5V19M6 13l6 6 6-6"/>',
    arrowRight:'<path d="M4.5 12h15M13 5.5l6.5 6.5L13 18.5"/>',
    x:'<path d="M6 6l12 12M18 6 6 18"/>',
    copy:'<rect x="8.6" y="8.6" width="11.9" height="11.9" rx="2.2"/><path d="M15.4 5.4a2 2 0 0 0-2-2H5.5a2 2 0 0 0-2 2v7.9a2 2 0 0 0 2 2"/>',
    plus:'<path d="M12 5v14M5 12h14"/>',
    play:'<path d="M7.5 5 18.5 12 7.5 19z"/>',
    stop:'<rect x="6.5" y="6.5" width="11" height="11" rx="2.2"/>',
    lock:'<rect x="4.5" y="10.4" width="15" height="10.1" rx="2.4"/><path d="M8 10.4V7.7a4 4 0 0 1 8 0v2.7"/>',
    shield:'<path d="M12 3.2 19.5 6v6c0 4.4-3.2 7.6-7.5 8.8C7.7 19.6 4.5 16.4 4.5 12V6z"/>',
    globe:'<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3c2.6 2.4 4 5.6 4 9s-1.4 6.6-4 9c-2.6-2.4-4-5.6-4-9s1.4-6.6 4-9z"/>',
    info:'<circle cx="12" cy="12" r="9"/><path d="M12 11v5.6M12 7.7h.01"/>',
    file:'<path d="M14 3.5H7a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8.5z"/><path d="M14 3.5v5h5"/>',
    image:'<rect x="3" y="4.5" width="18" height="15" rx="2.4"/><circle cx="8.6" cy="9.8" r="1.5"/><path d="M4 17.2l4.6-4.6 3.4 3.4 3-2.5 4.6 4.2"/>',
    film:'<rect x="3" y="4.5" width="18" height="15" rx="2.4"/><path d="M8 4.5v15M16 4.5v15M3 12h18"/>',
    music:'<path d="M9 18V6.4l10-2v11"/><circle cx="6.6" cy="18" r="2.4"/><circle cx="16.6" cy="15.4" r="2.4"/>',
    send:'<path d="M21 3.6 10.4 14.2"/><path d="M21 3.6 14.4 21l-4-7.4-7.4-4z"/>',
    refresh:'<path d="M20.5 12a8.5 8.5 0 1 1-2.6-6.1"/><path d="M20.6 4v4.6H16"/>',
    trash:'<path d="M4.5 7h15M9.6 7V4.8h4.8V7M6.6 7l.9 12.3a1.7 1.7 0 0 0 1.7 1.6h5.6a1.7 1.7 0 0 0 1.7-1.6L17.4 7"/>',
    search:'<circle cx="11" cy="11" r="6.6"/><path d="M15.8 15.8 20.5 20.5"/>',
    chevronRight:'<path d="M9.5 5.5 16 12l-6.5 6.5"/>',
    chevronLeft:'<path d="M14.5 5.5 8 12l6.5 6.5"/>',
    clock:'<circle cx="12" cy="12" r="9"/><path d="M12 7v5.4l3.4 2"/>',
    volume:'<path d="M11 5 6.6 9H3.6v6h3L11 19z"/><path d="M15.4 9.2a4 4 0 0 1 0 5.6M18.4 6.6a8 8 0 0 1 0 10.8"/>',
    power:'<path d="M12 3.6v8.2"/><path d="M7.6 6.6a7.5 7.5 0 1 0 8.8 0"/>',
    phone:'<rect x="6.6" y="2.5" width="10.8" height="19" rx="2.6"/><path d="M10.6 5.4h2.8M11 18.6h2"/>',
    laptop:'<rect x="4" y="5" width="16" height="10.6" rx="2"/><path d="M2.4 19h19.2"/>',
    users:'<circle cx="9" cy="8" r="3.2"/><path d="M3.6 20a5.4 5.4 0 0 1 10.8 0"/><path d="M16 5.4a3.2 3.2 0 0 1 0 6.2M17.6 20a5.6 5.6 0 0 0-1.6-3.9"/>',
    zap:'<path d="M13 2.6 4.6 13.4H11l-1 8L19.4 10H13z"/>',
    activity:'<path d="M3 12h3.8l2.4-7 4.6 14 2.4-7H21"/>',
    drive:'<rect x="2.5" y="4.8" width="19" height="6.2" rx="2"/><rect x="2.5" y="13" width="19" height="6.2" rx="2"/><path d="M6.6 8h.01M6.6 16.1h.01"/>',
    camera:'<path d="M3 8.6a2 2 0 0 1 2-2h2l1.4-2.1h7.2L17 6.6h2a2 2 0 0 1 2 2v8.8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><circle cx="12" cy="12.8" r="3.4"/>',
    maximize:'<path d="M4 9V5.6A1.6 1.6 0 0 1 5.6 4H9M15 4h3.4A1.6 1.6 0 0 1 20 5.6V9M20 15v3.4a1.6 1.6 0 0 1-1.6 1.6H15M9 20H5.6A1.6 1.6 0 0 1 4 18.4V15"/>',
    crop:'<path d="M6.6 2.6v14.8h14.8"/><path d="M2.6 6.6h14.8v14.8"/>',
    sliders:'<path d="M4 7h9M18.5 7H20M4 17h4M13 17h7"/><circle cx="15.5" cy="7" r="2.3"/><circle cx="10.5" cy="17" r="2.3"/>',
    move:'<path d="M12 3.4v17.2M3.4 12h17.2"/><path d="M12 3.4 9.6 5.8M12 3.4l2.4 2.4M12 20.6l-2.4-2.4M12 20.6l2.4-2.4M3.4 12l2.4-2.4M3.4 12l2.4 2.4M20.6 12l-2.4-2.4M20.6 12l-2.4 2.4"/>',
    eye:'<path d="M2.4 12S6 5.6 12 5.6 21.6 12 21.6 12 18 18.4 12 18.4 2.4 12 2.4 12z"/><circle cx="12" cy="12" r="3"/>',
    hash:'<path d="M5 9h14M5 15h14M9.4 4 7.9 20M16.1 4l-1.5 16"/>',
    sun:'<circle cx="12" cy="12" r="4"/><path d="M12 2.6v2M12 19.4v2M2.6 12h2M19.4 12h2M5.4 5.4l1.4 1.4M17.2 17.2l1.4 1.4M18.6 5.4l-1.4 1.4M6.8 17.2 5.4 18.6"/>',
    moon:'<path d="M20 14.6A8.5 8.5 0 0 1 9.4 4 8.5 8.5 0 1 0 20 14.6z"/>',
    layers:'<path d="M12 3 3 8l9 5 9-5z"/><path d="M3 13l9 5 9-5"/>',
    download:'<path d="M12 3.6v11M7.6 10.6 12 15l4.4-4.4"/><path d="M4.6 20.4h14.8"/>',
    upload:'<path d="M12 20.4v-11M7.6 13.4 12 9l4.4 4.4"/><path d="M4.6 3.6h14.8"/>',
    sparkle:'<path d="M12 3.4l1.7 4.6 4.6 1.7-4.6 1.7L12 16l-1.7-4.6L5.7 9.7l4.6-1.7z"/><path d="M18.4 16.4l.7 1.8 1.8.7-1.8.7-.7 1.8-.7-1.8-1.8-.7 1.8-.7z"/>',
    drag:'<path d="M8 9.5a1.5 1.5 0 1 1 3 0v3.9M11 12V7.6a1.5 1.5 0 1 1 3 0v5.8M14 11.6a1.5 1.5 0 1 1 3 0v3.4"/><path d="M17 12.6a1.5 1.5 0 1 1 3 0v2.9c0 3.4-2.5 5.9-5.9 5.9h-1.7c-2 0-3.2-1-4.2-2.4l-3-4.4a1.5 1.5 0 0 1 2.4-1.8l1.4 1.6"/>'
  };

  function icon(name, size) {
    var d = ICONS[name];
    if (!d) return '';
    var s = size ? ' width="' + size + '" height="' + size + '"' : '';
    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"' + s + ' aria-hidden="true" focusable="false">' + d + '</svg>';
  }

  function hydrateIcons(root) {
    var scope = root || document;
    var nodes = scope.querySelectorAll('[data-icon]');
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i];
      var svg = icon(n.getAttribute('data-icon'), n.getAttribute('data-size'));
      n.removeAttribute('data-icon');
      if (!svg) continue;
      if (n.textContent.trim().length) n.insertAdjacentHTML('afterbegin', svg);
      else n.innerHTML = svg;
    }
  }

  /* ---------------- DOM helpers ---------------- */
  function $(sel, root) { return (root || document).querySelector(sel); }
  function $$(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }
  function on(el, ev, fn) { if (el) el.addEventListener(ev, fn); return el; }
  function esc(str) {
    return String(str == null ? '' : str)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
  function bytes(n) {
    if (n >= 1073741824) return (n / 1073741824).toFixed(2) + ' GB';
    if (n >= 1048576) return (n / 1048576).toFixed(1) + ' MB';
    if (n >= 1024) return Math.round(n / 1024) + ' KB';
    return n + ' B';
  }
  function duration(sec) {
    sec = Math.max(0, Math.round(sec));
    if (sec < 60) return sec + ' second' + (sec === 1 ? '' : 's');
    var m = Math.floor(sec / 60), h = Math.floor(m / 60);
    if (h > 0) return h + 'h ' + String(m % 60).padStart(2, '0') + 'm';
    return m + 'm ' + String(sec % 60).padStart(2, '0') + 's';
  }
  function clock(sec) {
    var m = Math.floor(sec / 60), s = sec % 60;
    return String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
  }

  /* ---------------- Tiny observable store ---------------- */
  function store(initial) {
    var subs = [];
    var api = {
      state: initial || {},
      get: function (k) { return k === undefined ? api.state : api.state[k]; },
      set: function (patch, meta) {
        Object.assign(api.state, patch);
        api.emit(patch, meta || {});
      },
      sub: function (fn) { subs.push(fn); return function () { subs = subs.filter(function (f) { return f !== fn; }); }; },
      emit: function (patch, meta) {
        subs.forEach(function (fn) { try { fn(api.state, patch || {}, meta || {}); } catch (e) { console.error(e); } });
      }
    };
    return api;
  }

  /* ---------------- Toast ---------------- */
  var toastTimer = null;
  function toast(msg, host) {
    var node = document.getElementById('toast');
    if (!node) {
      node = document.createElement('div');
      node.id = 'toast'; node.className = 'toast';
      (host || document.body).appendChild(node);
    }
    node.textContent = msg;
    node.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { node.classList.remove('show'); }, 2200);
  }

  /* ---------------- Standalone shell fitting ---------------- */
  function fit(shell, w, h) {
    var inFrame = false;
    try { inFrame = window.self !== window.top; } catch (e) { inFrame = true; }
    if (inFrame || !shell) return;
    function apply() {
      var s = Math.min(1, window.innerWidth / w, window.innerHeight / h);
      shell.style.transform = 'scale(' + s + ')';
    }
    window.addEventListener('resize', apply);
    apply();
  }

  /* ---------------- postMessage bridge (hub <-> frames) ---------------- */
  function bridge(api, handlers) {
    handlers = handlers || {};
    window.addEventListener('message', function (ev) {
      var d = ev.data || {};
      if (d.type === 'link:setState' && handlers.onSetState) handlers.onSetState(d.status);
      else if (d.type === 'link:nav' && handlers.onNav) handlers.onNav(d.screen);
      else if (d.type === 'link:action' && handlers.onAction) handlers.onAction(d.action);
    });
    function report() {
      var payload = {
        type: 'link:state',
        status: api.state.status,
        screen: handlers.screen ? handlers.screen() : '',
        label: handlers.label ? handlers.label() : ''
      };
      try { if (window.parent && window.parent !== window) window.parent.postMessage(payload, '*'); } catch (e) {}
    }
    api.sub(report);
    report();
    return report;
  }

  global.LinkUI = {
    ICONS: ICONS, icon: icon, hydrateIcons: hydrateIcons,
    $: $, $$: $$, on: on, esc: esc, bytes: bytes, duration: duration, clock: clock,
    store: store, toast: toast, fit: fit, bridge: bridge
  };
})(window);
