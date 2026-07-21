/* ============================================================
   TourBuddy UI — Interaction Helpers
   ============================================================ */
(function () {
  'use strict';

  /* ────────── IntersectionObserver — fade-in sections ────────── */
  function initReveal() {
    const targets = document.querySelectorAll('.tb-reveal');
    if (!('IntersectionObserver' in window) || targets.length === 0) {
      targets.forEach((el) => el.classList.add('tb-revealed'));
      return;
    }
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('tb-revealed');
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
    );
    targets.forEach((el) => io.observe(el));
  }

  /* ────────── Ripple click effect ────────── */
  function initRipple() {
    document.addEventListener('click', (e) => {
      const btn = e.target.closest('.tb-ripple, .tb-btn, button[data-ripple]');
      if (!btn) return;
      const rect = btn.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      const wave = document.createElement('span');
      wave.className = 'tb-ripple-wave';
      wave.style.width = wave.style.height = size + 'px';
      wave.style.left = e.clientX - rect.left - size / 2 + 'px';
      wave.style.top = e.clientY - rect.top - size / 2 + 'px';
      btn.appendChild(wave);
      setTimeout(() => wave.remove(), 650);
    });
  }

  /* ────────── Number counter animation ────────── */
  function animateCount(el) {
    const target = parseFloat(el.dataset.count);
    if (isNaN(target)) return;
    const dur = parseInt(el.dataset.duration || '1200', 10);
    const decimals = parseInt(el.dataset.decimals || '0', 10);
    const start = performance.now();
    function tick(now) {
      const t = Math.min((now - start) / dur, 1);
      const eased = 1 - Math.pow(1 - t, 3);
      const val = target * eased;
      el.textContent = decimals > 0
        ? val.toFixed(decimals)
        : Math.floor(val).toLocaleString('vi-VN');
      if (t < 1) requestAnimationFrame(tick);
      else el.dataset.counted = 'true';
    }
    requestAnimationFrame(tick);
  }

  function initCounters() {
    const els = document.querySelectorAll('.tb-count[data-count]');
    if (els.length === 0) return;
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            animateCount(entry.target);
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.4 }
    );
    els.forEach((el) => io.observe(el));
  }

  /* ────────── Progress bars ────────── */
  function initProgress() {
    const bars = document.querySelectorAll('.tb-progress-bar[data-value]');
    if (bars.length === 0) return;
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.style.width = entry.target.dataset.value + '%';
            io.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.3 }
    );
    bars.forEach((el) => io.observe(el));
  }

  /* ────────── Toast system ────────── */
  function ensureStack() {
    let stack = document.querySelector('.tb-toast-stack');
    if (!stack) {
      stack = document.createElement('div');
      stack.className = 'tb-toast-stack';
      document.body.appendChild(stack);
    }
    return stack;
  }

  const ICONS = {
    success: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>',
    error:   '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>',
    warning: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>',
    info:    '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>',
  };

  window.tbToast = function (options) {
    const stack = ensureStack();
    const opt = Object.assign(
      { type: 'info', title: '', msg: '', duration: 3800 },
      typeof options === 'string' ? { msg: options } : options || {}
    );
    const el = document.createElement('div');
    el.className = 'tb-toast tb-toast-' + opt.type;
    el.innerHTML =
      '<div class="tb-toast-icon">' + (ICONS[opt.type] || ICONS.info) + '</div>' +
      '<div class="tb-toast-body">' +
        (opt.title ? '<div class="tb-toast-title"></div>' : '') +
        '<div class="tb-toast-msg"></div>' +
      '</div>';
    if (opt.title) el.querySelector('.tb-toast-title').textContent = opt.title;
    el.querySelector('.tb-toast-msg').textContent = opt.msg || '';
    stack.appendChild(el);
    setTimeout(() => {
      el.classList.add('tb-toast-out');
      setTimeout(() => el.remove(), 320);
    }, opt.duration);
    el.addEventListener('click', () => {
      el.classList.add('tb-toast-out');
      setTimeout(() => el.remove(), 320);
    });
  };

  /* ────────── Refresh Lucide icons when DOM changes ────────── */
  function refreshIcons() {
    if (window.lucide && typeof window.lucide.createIcons === 'function') {
      try { window.lucide.createIcons(); } catch (e) { /* noop */ }
    }
  }

  /* ────────── Init ────────── */
  function init() {
    initReveal();
    initRipple();
    initCounters();
    initProgress();
    refreshIcons();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // expose for re-init after dynamic content
  window.tbUI = { init, refreshIcons, animateCount };
})();
