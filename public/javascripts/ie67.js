$(function() {
  $('form input.text, form select').keyup(function(event) {
    if (event.keyCode == 13) {
      $(this).closest('form').submit();
    }
  });
  $('form button').click(function(event) {
    $(this).closest('form').submit();
  });
});