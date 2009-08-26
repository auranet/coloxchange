Router = new(function(routes) {
  this.named_routes = routes;
  this.url = window.location.toString().split('/').slice(0, 3).join('/');
  this.bindRoute = function(key, segments) {
    this[key] = function() {
      var route = '';
      var options = arguments[0] || {};
      var errors = [];
      for (var i = 0; i < segments.length; i++) {
        var segment = segments[i];
        if (segment.key) {
          if (segment.regexp) {
            if (options[segment.key]) {
              if (segment.regexp.test(options[segment.key])) {
                route += options[segment.key];
              } else {
                errors.push('`' + segment.key + '` (' + options[segment.key] + ') does not match requirements: ' + segment.regexp);
              }
            } else {
              errors.push('`' + segment.key + '` is required')
            }
          } else {
            alert('key required but no regexp');
          }
        } else {
          if (!segment.is_optional) {
            route += segment.value;
          }
        }
      }
      if (errors.length > 0) {
        throw(errors.join(", "));
      }
      return route;
    };

    this[key + '_path'] = function() {
      return this[key].apply(this, arguments);
    };

    this[key + '_url'] = function() {
      var route = this[key + '_path'].apply(this, arguments);
      return this.url + route;
    };
  };
  for (var key in routes) {
    this.bindRoute(key, routes[key]);
  }
})({"logout": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "logout"}, {"is_optional": true, "value": "/", "raw": true}], "root": [{"is_optional": true, "value": "/", "raw": true}], "bandwidth_quote": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "quote"}, {"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "bandwidth"}, {"is_optional": true, "value": "/", "raw": true}], "search": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "search"}, {"is_optional": true, "value": "/", "raw": true}], "data_center_search": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "data-centers"}, {"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "search"}, {"is_optional": false, "value": ".", "raw": true}, {"is_optional": false, "key": "format"}, {"is_optional": true, "value": "/", "raw": true}], "page": [{"is_optional": true, "value": "/", "raw": true}, {"is_optional": true, "key": "path"}, {"is_optional": true, "value": "/", "raw": true}], "colocation_quote": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "quote"}, {"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "colocation"}, {"is_optional": true, "value": "/", "raw": true}], "data_center": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "data-centers"}, {"is_optional": true, "value": "/", "raw": true}, {"regexp": /[a-z0-9-]+/, "is_optional": true, "key": "id"}, {"is_optional": true, "value": "/", "raw": true}], "equipment_quote": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "quote"}, {"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "equipment"}, {"is_optional": true, "value": "/", "raw": true}], "quote_submit": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "quote"}, {"is_optional": true, "value": "/", "raw": true}], "contact_sent": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "contact"}, {"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "sent"}, {"is_optional": true, "value": "/", "raw": true}], "managed_services_quote": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "quote"}, {"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "managed-services"}, {"is_optional": true, "value": "/", "raw": true}], "quote": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "quote"}, {"is_optional": true, "value": "/", "raw": true}], "quote_sent": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "quote"}, {"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "sent"}, {"is_optional": true, "value": "/", "raw": true}], "contact": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "contact_sent"}, {"is_optional": true, "value": "/", "raw": true}], "login": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "login"}, {"is_optional": true, "value": "/", "raw": true}], "market_quote": [{"is_optional": false, "value": "/", "raw": true}, {"is_optional": false, "value": "quote"}, {"is_optional": false, "value": "/", "raw": true}, {"regexp": /[A-Z]{2,4}/, "is_optional": false, "key": "state"}, {"is_optional": false, "value": "/", "raw": true}, {"regexp": /[A-Za-z0-9\.-]+/, "is_optional": false, "key": "city"}, {"is_optional": true, "value": "/", "raw": true}]});
