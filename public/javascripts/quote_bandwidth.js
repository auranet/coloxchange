$(function() {
  $('a.append').click(function(event) {
    event.preventDefault();
    event.stopPropagation();
    var appendTo = $('#' + this.rel);
    var append = $('#' + this.rel + '_appendable').children(':first').clone();
    appendTo.append(append);
    append.find('.replace').replace();
    append.find('a.remove').click(function(event) {
      event.preventDefault();
      event.stopPropagation();
      $(this).closest(this.rel).remove();
    });
  });
});