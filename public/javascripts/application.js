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

// JSRoutes 1.0
// Copyright (C) 2009 Flip Sasser
// http://x451.com
Router=new(function(routes){this.url=window.location.toString().split('/').slice(0,3).join('/');this.bindRoute=function(key,segments){this[key]=function(){var route='';var options=arguments[0]||{};var errors=[];for(var i=0;i<segments.length;i++){var segment=segments[i];if(segment.key){if(segment.regexp){if(options[segment.key]){if(segment.regexp.test(options[segment.key])){route+=options[segment.key];}else{errors.push('`'+segment.key+'` ('+options[segment.key]+') does not match requirements: '+segment.regexp);}}else{errors.push('`'+segment.key+'` is required')}}else{alert('key required but no regexp');}}else{if(!segment.is_optional){route+=segment.value;}}}if(errors.length>0){throw(errors.join(", "));}return route;};this[key+'_path']=function(){return this[key].apply(this,arguments);};this[key+'_url']=function(){var route=this[key+'_path'].apply(this,arguments);return this.url+route;};};for(var key in routes){this.bindRoute(key,routes[key]);}this.named_routes=routes;this.bindRoute=null;})({"data_center_search":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"data-centers"},{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"search"},{"is_optional":false,"value":".","raw":true},{"is_optional":false,"key":"format"},{"is_optional":true,"value":"/","raw":true}],"quote":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"quote"},{"is_optional":true,"value":"/","raw":true}],"colocation_quote":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"quote"},{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"colocation"},{"is_optional":true,"value":"/","raw":true}],"data_center":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"data-centers"},{"is_optional":true,"value":"/","raw":true},{"regexp":/[a-z0-9-]+/,"is_optional":true,"key":"id"},{"is_optional":true,"value":"/","raw":true}],"equipment_quote":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"quote"},{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"equipment"},{"is_optional":true,"value":"/","raw":true}],"quote_submit":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"quote"},{"is_optional":true,"value":"/","raw":true}],"contact_sent":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"contact"},{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"sent"},{"is_optional":true,"value":"/","raw":true}],"managed_services_quote":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"quote"},{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"managed-services"},{"is_optional":true,"value":"/","raw":true}],"page":[{"is_optional":true,"value":"/","raw":true},{"is_optional":true,"key":"path"},{"is_optional":true,"value":"/","raw":true}],"quote_sent":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"quote"},{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"sent"},{"is_optional":true,"value":"/","raw":true}],"login":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"login"},{"is_optional":true,"value":"/","raw":true}],"search":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"search"},{"is_optional":true,"value":"/","raw":true}],"market_quote":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"quote"},{"is_optional":false,"value":"/","raw":true},{"regexp":/[A-Z]{2,4}/,"is_optional":false,"key":"state"},{"is_optional":false,"value":"/","raw":true},{"regexp":/[A-Za-z0-9\.-]+/,"is_optional":false,"key":"city"},{"is_optional":true,"value":"/","raw":true}],"contact":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"contact_sent"},{"is_optional":true,"value":"/","raw":true}],"logout":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"logout"},{"is_optional":true,"value":"/","raw":true}],"root":[{"is_optional":true,"value":"/","raw":true}],"bandwidth_quote":[{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"quote"},{"is_optional":false,"value":"/","raw":true},{"is_optional":false,"value":"bandwidth"},{"is_optional":true,"value":"/","raw":true}]});//EndJSRoutes (DoNotRemoveThisComment!)
