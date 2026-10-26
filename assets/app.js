/* 远景记账落地页 —— 交互脚本（无依赖，渐进增强） */
(function () {
  'use strict';

  /* ---------- 移动端导航开关 ---------- */
  var toggle = document.getElementById('nav-toggle');
  var nav = document.getElementById('site-nav');

  if (toggle && nav) {
    var setNav = function (open) {
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      nav.classList.toggle('is-open', open);
    };

    toggle.addEventListener('click', function () {
      setNav(toggle.getAttribute('aria-expanded') !== 'true');
    });

    // 点导航项后收起；Esc 也收起
    nav.addEventListener('click', function (e) {
      if (e.target.closest('a')) setNav(false);
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') setNav(false);
    });

    // 视口变宽后复位，避免"半开"状态残留
    window.addEventListener('resize', function () {
      if (window.innerWidth > 760) setNav(false);
    });
  }

  /* ---------- 页脚年份 ---------- */
  var year = document.getElementById('year');
  if (year) year.textContent = String(new Date().getFullYear());

  /* ---------- 滚动入场（仅在支持 IntersectionObserver 时启用） ---------- */
  var reduceMotion =
    window.matchMedia &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (!reduceMotion && 'IntersectionObserver' in window) {
    var targets = document.querySelectorAll(
      '.feature-card, .glass-panel, .screen-figure, .design-list li, .faq details, .section-head'
    );

    var observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-visible');
            observer.unobserve(entry.target);
          }
        });
      },
      { rootMargin: '0px 0px -8% 0px', threshold: 0.08 }
    );

    targets.forEach(function (el, i) {
      el.classList.add('reveal');
      // 同一屏内错开一点，避免整片同时浮起
      el.style.transitionDelay = Math.min(i % 6, 5) * 60 + 'ms';
      observer.observe(el);
    });
  }
})();
