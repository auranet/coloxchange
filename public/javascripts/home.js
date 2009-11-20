$(function() {
  var items = $('#carousel .item');
  var links = $('#submenu a'), timeout, timeoutIndex = 0, timeoutLength = 5000;
  links.click(function(event) {
    if (timeout) {
      clearTimeout(timeout);
    }
    if (event) {
		  event.preventDefault();
	  }
	  links.removeClass('active');
	  var link = $(this);
	  var active = $('#carousel .item.active');
	  var next = active.next();
	  if (next.length == 0) {
	    next = items[0];
	  }
	  if (!active.hasClass(this.getAttribute('rel'))) {
	    active.addClass('fading').fadeOut(1000, function() {
	      active.css('display', '').removeClass('active fading');
	    });
	    next.addClass('animating');
      // var h2 = next.find('h2');
      // h2.css('top', -100);
      // next.find('h2').animate({top: 0}, 1000);
	    $('#carousel .item.' + this.getAttribute('rel')).addClass('active').css('display', '');
	    link.addClass('active');
	  }
  });
  var changeLinks = function() {
    timeoutIndex++;
    if (!links[timeoutIndex]) timeoutIndex = 0;
    $(links[timeoutIndex]).click();
    timeout = setTimeout(changeLinks, timeoutLength);
  };
  timeout = setTimeout(changeLinks, timeoutLength);
});