$(function() {
  $('.replace').replace();
  // if (jQuery.browser.safari) $('.search').each(function() { this.type = 'search'; });
  $('.options').options();
  $('.other').other();
  $('.toggle[rel]').click(function(event) {
    event.preventDefault();
    var toggle = $('#' + this.rel);
    if (toggle.length > 0) {
      toggle.slideToggle(1000);
      $('body').animate({scrollTop: toggle.offset().top}, 500);
    }
  });
  $('fieldset.collapsible legend').click(function(event) {
    $(this).parent().toggleClass('toggled');
  });
});

jQuery.fn.extend({
  options: function() {
    this.each(function() {
      var input = $(this);
      var value = input.val();
      input.change(function() {
        var className = input.attr('id') + '_' + value + '-options';
        $('.' + className).css('display', 'none');
        value = input.val();
        className = input.attr('id') + '_' + value + '-options';
        $('.' + className).css('display', '');
      });
    });
  },
  other: function() {
    this.each(function() {
      var input = $(this);
      var value = input.val();
      var id = input.attr('id');
      input.change(function() {
        var other = $('#' + id + '_other');
        value = input.val();
        if (value == 'other' && other.length == 0) {
          other = $('<input alt="Other..." class="large replace text" id="' + id + '_other" name="' + input.attr('name') + '" type="text" />');
          other.replace();
          input.attr('name', 'na');
          input.after(other);
        } else if (value != 'other' && other.length > 0) {
          input.attr('name', other.attr('name'));
          other.remove();
        }
      });
    });
  },
  replace: function() {
    var timeout;
    this.each(function() {
      var input = $(this);
      var alt = input.attr('alt');
      var val = input.val();
      if (val == '') input.val(alt);
      else if (val != alt) input.addClass('replaced');
    });
    this.blur(function() {
      var input = $(this);
      if (input.val() == '') {
        input.val(input.attr('alt')).removeClass('replaced');
        var close = input.data('close');
        if (close) timeout = setTimeout(function() {close.remove();}, 1);
      }
    });
    this.focus(function() {
      var input = $(this);
      if (input.val() == input.attr('alt')) input.val('').addClass('replaced');
    });
    this.keyup(function(event) {
      var input = $(this);
      if (event.keyCode == 27) {
        input.val('');
        input.blur();
      } else if (input.hasClass('close') && input.val() != '') {
        var close = input.data('close');
        if (!close) {
          close = $('<span id="search-cancel"></span>');
          input.data('close', close);
        }
        close.click(function() {
          input.val('');
          close.remove();
          input.focus();
        });
        if (close) input.after(close);
        
      }
    });
  }
});
