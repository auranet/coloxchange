$(function() {
  var items = $('#carousel .item');
  var links = $('#submenu a'), timeout, timeoutIndex = 0, timeoutLength = 2000;
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
    var next = items.filter('.' + link.attr('rel'));
	  if (!active.hasClass(link.attr('rel'))) {
	    active.addClass('fading').fadeOut(500, function() {
	      active.css('display', '').removeClass('active fading');
	    });
      next.addClass('animating active').css('display', '');
      var h2 = next.find('h2');
      h2.css('top', -100).animate({top: 0}, 1000);
      var p = next.find('p:first');
      p.css('left', -300).animate({left: 0}, 1000);
      var learnMore = next.find('p:last');
      learnMore.css('top', 100).animate({top: 0}, 1000, function() {
        next.removeClass('animating');
      });
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