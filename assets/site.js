// Bot previews: clicking the example prompt drops it into the input box.
document.querySelectorAll('.bot .chip').forEach(function (chip) {
  chip.addEventListener('click', function () {
    var input = chip.closest('.bot').querySelector('input');
    input.value = chip.textContent;
    input.focus();
  });
});

// Contact form: until a form service is chosen, open the visitor's email app with the message filled in.
var form = document.getElementById('cf');
if (form) {
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    var v = function (id) { return document.getElementById(id).value.trim(); };
    var lines = [
      v('cf-msg'),
      '',
      'Name: ' + v('cf-name'),
      'Email: ' + v('cf-email'),
      'Institution: ' + v('cf-inst'),
      'Please contact me: ' + (document.getElementById('cf-contact').checked ? 'Yes' : 'No'),
      'Send me updates: ' + (document.getElementById('cf-upd').checked ? 'Yes' : 'No'),
    ];
    location.href = 'mailto:' + form.dataset.to +
      '?subject=' + encodeURIComponent('AI Starter Kit: ' + v('cf-topic')) +
      '&body=' + encodeURIComponent(lines.join('\n'));
    document.getElementById('cf-msgout').textContent = form.dataset.done;
  });
}

// Topic vote: pick up to "max" topics (or write your own under Other), then send. Until a form
// service is chosen, this opens the visitor's email app with their picks filled in.
document.querySelectorAll('.vote').forEach(function (box) {
  var max = parseInt(box.dataset.max, 10) || 0;
  var cards = Array.prototype.slice.call(box.querySelectorAll('.vote-card'));
  var otherCard = box.querySelector('.vote-other');
  var otherText = otherCard ? otherCard.querySelector('textarea') : null;
  var send = box.querySelector('.vote-send');
  var count = box.querySelector('.vote-count');
  var out = box.querySelector('.vote-out');
  var picked = function () { return cards.filter(function (c) { return c.classList.contains('picked'); }); };
  var full = function () { return max > 0 && picked().length >= max; };
  function update() {
    var n = picked().length;
    cards.forEach(function (c) {
      c.querySelector('.vote-btn').disabled = full() && !c.classList.contains('picked');
    });
    count.textContent = (box.dataset.count || '').replace('{n}', n).replace('{max}', max);
    send.disabled = n === 0;
  }
  function set(card, on) {
    card.classList.toggle('picked', on);
    card.querySelector('.vote-btn').setAttribute('aria-pressed', on ? 'true' : 'false');
    update();
  }
  cards.forEach(function (c) {
    c.querySelector('.vote-btn').addEventListener('click', function () {
      var on = !c.classList.contains('picked');
      set(c, on);
      if (on && c === otherCard && !otherText.value.trim()) otherText.focus();
    });
  });
  if (otherText) {
    otherText.addEventListener('input', function () {
      if (otherText.value.trim() && !otherCard.classList.contains('picked') && !full()) set(otherCard, true);
    });
  }
  send.addEventListener('click', function () {
    var lines = [box.dataset.intro + ':', ''];
    picked().forEach(function (c) {
      var title = c.querySelector('h3').textContent.trim();
      var extra = c === otherCard ? otherText.value.trim() : '';
      lines.push('- ' + title + (extra ? ': ' + extra : ''));
    });
    location.href = 'mailto:' + box.dataset.to +
      '?subject=' + encodeURIComponent(box.dataset.subject) +
      '&body=' + encodeURIComponent(lines.join('\n'));
    out.textContent = box.dataset.done;
  });
  update();
});
