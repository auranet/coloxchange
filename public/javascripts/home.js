$(function() {
  var links = $('#submenu a'), timeout, timeoutIndex = 0, timeoutLength = 5000;
  links.click(function(event) {
    if (timeout) {
      clearTimeout(timeout);
    }
    if (event) {
		  event.preventDefault();
	  }
	  var active = $('#carousel .item.active');
	  if (!active.hasClass(this.getAttribute('rel'))) {
	    active.addClass('fading').fadeOut(1000, function() {
	      active.css('display', '').removeClass('active fading');
	    });
	    $('#carousel .item.' + this.getAttribute('rel')).addClass('active').css('display', '');
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