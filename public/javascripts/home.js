$(function() {
  lastBlock = $("#carousel-colocation");
  maxWidth = 560;
  minWidth = 102;
  $("#carousel li").hover(function() {
    $(lastBlock).animate({width: minWidth + 'px'}, {queue: false, duration: 400});
    $(this).animate({width: maxWidth + 'px'}, {queue: false, duration: 400});
    lastBlock = this;
  });
});