// Teaching & Learning page: the framework model, the comparison tabs, copy buttons and the
// Prompt & Skill Library. All wording comes from the Google Doc via the #tl-data block.
(function () {
  var holder = document.getElementById('tl-data');
  if (!holder) return;
  var D = JSON.parse(holder.textContent);
  var L = D.labels;
  var parts = D.parts;
  var byKey = {};
  parts.forEach(function (p) { byKey[p.key] = p; });

  function esc(s) {
    return String(s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; });
  }
  function fill(template, n) {
    return String(template || '').replace(/\{n\}/g, n).replace(/\{total\}/g, parts.length);
  }

  /* ---- framework ---- */
  var det = document.getElementById('fwdetail');
  var fw = document.getElementById('fw');
  var prog = document.getElementById('fwprog');
  var seen = {};
  function showNode(k) {
    var p = byKey[k];
    if (!p) return;
    seen[k] = true;
    document.querySelectorAll('.node').forEach(function (b) {
      b.setAttribute('aria-pressed', b.dataset.node === k ? 'true' : 'false');
      b.classList.toggle('seen', !!seen[b.dataset.node]);
    });
    var n = Object.keys(seen).length;
    prog.textContent = n === parts.length ? fill(L.progressDone, n) : fill(L.progress, n);
    var i = parts.indexOf(p);
    var nx = parts[(i + 1) % parts.length];
    det.innerHTML =
      '<span class="kick">' + (i + 1) + ' · ' + esc(p.name) + '</span><p class="q">' + esc(p.q) + '</p>' +
      (p.ai.length ? '<div class="blk"><h4>' + esc(L.helps) + '</h4><ul>' + p.ai.map(function (x) { return '<li>' + esc(x) + '</li>'; }).join('') + '</ul></div>' : '') +
      (p.sci ? '<div class="blk"><h4>' + esc(L.science) + '</h4><p class="sci">' + esc(p.sci) + '</p></div>' : '') +
      (p.uses.length ? '<div class="blk"><h4>' + esc(L.uses) + '</h4><div class="uses">' + p.uses.map(function (u) {
        return '<a href="' + esc(u.href) + '"' + (u.ext ? ' target="_blank" rel="noopener"' : '') + (u.filter ? ' data-goto="' + esc(p.key) + '"' : '') + '>' + esc(u.label) + (u.ext ? ' ↗' : ' →') + '</a>';
      }).join('') + '</div></div>' : '') +
      (parts.length > 1 ? '<button class="btn ghost nextp" type="button" data-next="' + esc(nx.key) + '">' + esc(L.next) + ' ' + esc(nx.name) + ' →</button>' : '');
  }
  if (fw && parts.length) {
    document.querySelectorAll('.node').forEach(function (b) {
      b.addEventListener('click', function () { fw.classList.add('touched'); showNode(b.dataset.node); });
    });
    det.addEventListener('click', function (e) {
      var nb = e.target.closest('[data-next]');
      if (nb) { fw.classList.add('touched'); showNode(nb.dataset.next); return; }
      var a = e.target.closest('a[data-goto]');
      if (!a) return;
      e.preventDefault();
      setPart(a.dataset.goto);
      document.getElementById('tl-library').scrollIntoView();
    });
    showNode(parts[0].key);
  }

  /* ---- comparison ---- */
  function showVs(i) {
    var v = D.comparisons[i];
    if (!v) return;
    document.querySelectorAll('.vs-tab').forEach(function (t) { t.setAttribute('aria-selected', +t.dataset.vs === i ? 'true' : 'false'); });
    document.getElementById('vsq').textContent = v.q;
    document.getElementById('vsa').innerHTML = v.a;
    document.getElementById('vsaw').textContent = v.aw;
    document.getElementById('vsb').innerHTML = v.b;
    document.getElementById('vsbw').textContent = v.bw;
  }
  document.querySelectorAll('.vs-tab').forEach(function (t) { t.addEventListener('click', function () { showVs(+t.dataset.vs); }); });
  showVs(0);

  /* ---- copy helper ---- */
  function copy(txt, cb) {
    function done() { if (cb) cb(); }
    function fallback() {
      var ta = document.createElement('textarea');
      ta.value = txt; ta.style.position = 'fixed'; ta.style.opacity = '0';
      document.body.appendChild(ta); ta.select();
      try { document.execCommand('copy'); } catch (e) {}
      document.body.removeChild(ta); done();
    }
    try { navigator.clipboard.writeText(txt).then(done, fallback); } catch (e) { fallback(); }
  }
  function flash(el, msg) { el.textContent = msg; setTimeout(function () { el.textContent = ''; }, 2200); }
  document.querySelectorAll('#tasks [data-copy]').forEach(function (b) {
    b.addEventListener('click', function () {
      var t = b.closest('.task');
      copy(t.querySelector('pre').textContent, function () { flash(t.querySelector('.ok'), L.copied); });
    });
  });

  /* ---- library ---- */
  var fN = 'all', fT = 'all', lib = document.getElementById('lib');
  function renderLib() {
    if (!lib) return;
    var rows = D.library.filter(function (x) { return (fN === 'all' || x.n === fN) && (fT === 'all' || x.t === fT); });
    lib.innerHTML = rows.length ? rows.map(function (x) {
      var idx = D.library.indexOf(x);
      var skill = x.t === 'skill';
      var inner = skill ? '<ol>' + x.steps.map(function (s) { return '<li>' + esc(s) + '</li>'; }).join('') + '</ol>' : '<pre>' + esc(x.body) + '</pre>';
      var part = byKey[x.n];
      return '<div class="item' + (skill ? ' skill' : '') + '"><div class="meta"><span class="ty">' + esc(skill ? L.skillType : L.promptType) + '</span>' +
        (part ? '<span class="nd">' + esc(part.name) + '</span>' : '') + '</div><h3>' + esc(x.h) + '</h3><p>' + esc(x.d) + '</p>' + inner +
        '<div class="act"><button class="ibtn" type="button" data-cp="' + idx + '">' + esc(skill ? L.copySkill : L.copyPrompt) + '</button><span class="ok" aria-live="polite"></span></div></div>';
    }).join('') : '<p class="lib-empty">' + esc(L.empty) + '</p>';
  }
  if (lib) {
    lib.addEventListener('click', function (e) {
      var b = e.target.closest('[data-cp]');
      if (!b) return;
      var x = D.library[+b.dataset.cp];
      var txt = x.t === 'prompt' ? x.body : (L.skillIntro + '\n' + x.h + ': ' + x.d + '\n' + x.steps.map(function (s, i) { return (i + 1) + '. ' + s; }).join('\n'));
      copy(txt, function () { flash(b.nextElementSibling, L.libCopied); });
    });
  }
  function setPart(n) {
    fN = n;
    document.querySelectorAll('[data-f]').forEach(function (c) { c.setAttribute('aria-pressed', c.dataset.f === n ? 'true' : 'false'); });
    renderLib();
  }
  document.querySelectorAll('[data-f]').forEach(function (c) { c.addEventListener('click', function () { setPart(c.dataset.f); }); });
  document.querySelectorAll('[data-t]').forEach(function (c) {
    c.addEventListener('click', function () {
      fT = c.dataset.t;
      document.querySelectorAll('[data-t]').forEach(function (d) { d.setAttribute('aria-pressed', d.dataset.t === fT ? 'true' : 'false'); });
      renderLib();
    });
  });
  renderLib();
})();
