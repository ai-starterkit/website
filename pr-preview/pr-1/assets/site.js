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
