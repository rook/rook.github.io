// rook.io: small progressive enhancements. Everything except the theme toggle works without JS.
(function () {
  'use strict';
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // State lives in window.rookTheme (inline script in _layouts/default.html); the label follows data-theme, which
  // also changes with the system theme and other tabs.
  var theme = window.rookTheme;
  var root = document.documentElement;
  var toggles = document.querySelectorAll('[data-theme-toggle]');
  if (theme && toggles.length) {
    var themeNow = function () { return root.getAttribute('data-theme') === 'dark' ? 'dark' : 'light'; };
    var syncToggles = function () {
      var label = themeNow() === 'dark' ? 'Switch to light theme' : 'Switch to dark theme';
      toggles.forEach(function (b) { b.setAttribute('aria-label', label); b.setAttribute('title', label); });
    };
    toggles.forEach(function (b) {
      b.addEventListener('click', function () { theme.set(themeNow() === 'dark' ? 'light' : 'dark'); });
    });
    new MutationObserver(syncToggles).observe(root, { attributes: true, attributeFilter: ['data-theme'] });
    // Another tab stored a choice, removed it, or cleared localStorage (key null): follow it.
    window.addEventListener('storage', function (e) {
      if (e.key === theme.key || e.key === null) theme.sync(e.key === null ? null : e.newValue);
    });
    syncToggles();
  }

  var nav = document.getElementById('nav');
  if (nav) {
    var onScroll = function () { nav.classList.toggle('is-scrolled', window.scrollY > 4); };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
    var toggle = nav.querySelector('.nav__toggle');
    var sheet = nav.querySelector('.nav__sheet');
    var setSheet = function (open) {
      nav.classList.toggle('is-open', open);
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      // The ribbon above the nav scrolls away, so start the sheet at the nav's current bottom edge.
      sheet.style.top = open ? Math.round(nav.getBoundingClientRect().bottom) + 'px' : '';
      document.body.style.overflow = open ? 'hidden' : '';
    };
    toggle.addEventListener('click', function () { setSheet(!nav.classList.contains('is-open')); });
    sheet.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () { setSheet(false); });
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && nav.classList.contains('is-open')) { setSheet(false); toggle.focus(); }
    });
    // The sheet exists only below 64em (the md breakpoint in _scss/tokens.scss): close it when the viewport grows past it.
    var narrow = window.matchMedia && window.matchMedia('(max-width: 64em)');
    if (narrow) {
      var onWidth = function () { if (!narrow.matches && nav.classList.contains('is-open')) setSheet(false); };
      if (narrow.addEventListener) narrow.addEventListener('change', onWidth); else if (narrow.addListener) narrow.addListener(onWidth);
    }
    nav.querySelectorAll('.nav__group').forEach(function (btn) {
      var sub = document.getElementById(btn.getAttribute('aria-controls'));
      btn.addEventListener('click', function () {
        var open = btn.getAttribute('aria-expanded') !== 'true';
        btn.setAttribute('aria-expanded', open ? 'true' : 'false');
        if (sub) sub.hidden = !open;
      });
    });

    var canHover = window.matchMedia && window.matchMedia('(hover: hover)').matches;
    var dropdowns = nav.querySelectorAll('[data-dropdown]');
    function setOpen(dd, open) {
      dd.classList.toggle('is-open', open);
      var t = dd.querySelector('.dropdown__toggle');
      if (t) t.setAttribute('aria-expanded', open ? 'true' : 'false');
      if (open) dropdowns.forEach(function (o) { if (o !== dd) setOpen(o, false); });
    }
    dropdowns.forEach(function (dd) {
      dd.setAttribute('data-js', '');
      var toggleBtn = dd.querySelector('.dropdown__toggle');
      var menu = dd.querySelector('.dropdown__menu');
      var pressing = false;  // focus caused by a mouse/touch press is not keyboard focus: do not open on it
      var quiet = false;     // focus moved back to the toggle by Escape: keep the menu closed
      var byHover = false;   // opened by mouseenter: a click on the chevron keeps it open
      dd.addEventListener('pointerdown', function () { pressing = true; setTimeout(function () { pressing = false; }, 0); });
      if (canHover) {
        dd.addEventListener('mouseenter', function () { byHover = !dd.classList.contains('is-open'); setOpen(dd, true); });
        dd.addEventListener('mouseleave', function () { byHover = false; setOpen(dd, false); });
      }
      dd.addEventListener('focusin', function () { if (!pressing && !quiet) setOpen(dd, true); });
      dd.addEventListener('focusout', function (e) { if (!dd.contains(e.relatedTarget)) setOpen(dd, false); });
      toggleBtn.addEventListener('click', function () {
        if (byHover) { byHover = false; return; }
        setOpen(dd, !dd.classList.contains('is-open'));
      });
      dd.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape' || !dd.classList.contains('is-open')) return;
        e.preventDefault();
        setOpen(dd, false);
        if (menu.contains(document.activeElement)) {
          quiet = true;
          toggleBtn.focus();
          quiet = false;
        }
      });
    });
    document.addEventListener('click', function (e) {
      dropdowns.forEach(function (dd) { if (!dd.contains(e.target)) setOpen(dd, false); });
    });
  }

  function setupTabs(list, onSelect) {
    var tabs = list.querySelectorAll('[role="tab"]');
    function select(tab) {
      tabs.forEach(function (t) {
        var on = t === tab;
        t.setAttribute('aria-selected', on ? 'true' : 'false');
        t.tabIndex = on ? 0 : -1;
      });
      if (onSelect) onSelect(tab, tabs);
    }
    tabs.forEach(function (tab, i) {
      tab.addEventListener('click', function () { select(tab); });
      tab.addEventListener('keydown', function (e) {
        var j = null;
        if (e.key === 'ArrowRight') j = (i + 1) % tabs.length;
        else if (e.key === 'ArrowLeft') j = (i - 1 + tabs.length) % tabs.length;
        else if (e.key === 'Home') j = 0;
        else if (e.key === 'End') j = tabs.length - 1;
        if (j === null) return;
        e.preventDefault();
        tabs[j].focus();
        select(tabs[j]);
      });
    });
  }
  function showPanels(tab, tabs) {
    tabs.forEach(function (t) {
      var panel = document.getElementById(t.getAttribute('aria-controls'));
      if (panel) panel.hidden = t !== tab;
    });
  }

  document.querySelectorAll('[data-tabs] [role="tablist"]').forEach(function (list) { setupTabs(list, showPanels); });

  // Panels share one grid cell, so the stage keeps the tallest panel's height.
  var how = document.querySelector('[data-how]');
  if (how) {
    setupTabs(how.querySelector('[role="tablist"]'), function (tab, tabs) {
      showPanels(tab, tabs);
      how.querySelectorAll('.how__text').forEach(function (p) { p.hidden = p.getAttribute('data-for') !== tab.getAttribute('aria-controls'); });
      if (tab.dataset.demo === 'true') startDemo();
    });
  }

  var demoStarted = false;
  function startDemo() {
    if (demoStarted) return;
    var holder = document.getElementById('terminal-demo');
    if (!holder) return;
    demoStarted = true;
    holder.innerHTML = '<asciinema-player id="terminal-player" cols="' + holder.dataset.cols + '" rows="' + holder.dataset.rows +
      '" preload loop speed="1.25" font-size="medium"' + (reduceMotion ? '' : ' autoplay') + ' src="' + holder.dataset.src + '"></asciinema-player>';
  }

  var secnav = document.querySelector('[data-secnav]');
  if (secnav && 'IntersectionObserver' in window) {
    var links = secnav.querySelectorAll('a[href^="#"]');
    var strip = secnav.querySelector('.container');
    var sections = [];
    links.forEach(function (a) { sections.push(document.getElementById(a.getAttribute('href').slice(1))); });
    var visible = {};
    var current = null;
    function activate(id) {
      if (id === current) return;
      current = id;
      links.forEach(function (a) {
        var on = a.getAttribute('href') === '#' + id;
        if (on) {
          a.setAttribute('aria-current', 'true');
          var l = a.offsetLeft, r = l + a.offsetWidth;
          if (l < strip.scrollLeft || r > strip.scrollLeft + strip.clientWidth) {
            strip.scrollTo({ left: Math.max(0, l - 16), behavior: reduceMotion ? 'auto' : 'smooth' });
          }
        } else {
          a.removeAttribute('aria-current');
        }
      });
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) { visible[e.target.id] = e.isIntersecting; });
      var first = null;
      for (var i = 0; i < sections.length; i++) { if (sections[i] && visible[sections[i].id]) { first = sections[i].id; break; } }
      if (first) activate(first);
      else if (sections[0] && sections[0].getBoundingClientRect().top > window.innerHeight * 0.4) activate(null);
    }, { rootMargin: '-150px 0px -55% 0px' });
    sections.forEach(function (s) { if (s) io.observe(s); });
  }
})();
