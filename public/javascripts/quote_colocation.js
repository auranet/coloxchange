$(function(){
  var searchField = $('#data-center-search'), searchButton = $('#data-center-search-button');
  searchField.keypress(function(event) {
    if (event.keyCode == 13) {
      event.preventDefault();
      event.stopPropagation();
      searchButton.click();
    }
  });
  searchButton.click(function(event) {
    event.preventDefault();
    if (!searchField.hasClass('replaced')) return;
		console.log('searching');
    var results = $('#data-center-results');
    var table = results.find('table');
    var tbody = table.find('tbody');
    tbody.find('tr').each(function() {
      var boxes = $(this).find('input');
      if (!(boxes[0] && boxes[0].checked)) {
        $(this).remove();
      }
    });
    tbody.stripe();
    results.css('display', '');
    var loadingRow = $('<tr class="row"><td class="center" colspan="3"><img alt="Loading" src="/images/loading-light.gif" /></td></tr>');
    tbody.prepend(loadingRow);
    $.post(this.href, {zip: searchField.val()}, function(data) {
      if (data.data_centers && data.data_centers.length > 0) {
        $(data.data_centers.reverse()).each(function() {
          var id = 'data-center-row-' + this.slug;
          if ($('#' + id).length == 0) {
            var row = $('<tr class="row" id="' + id + '"><td style="width:10px;"><input id="data-center-' + this.slug + '" name="quote[data_centers][' + this.slug + '][include]" type="checkbox" value="true" /><input name="quote[data_centers][' + this.slug + '][include]" type="hidden" value="false" /></td><td><label for="data-center-' + this.slug + '">' + this.name + '<input name="quote[data_centers][' + this.slug + '][name]" type="hidden" value="' + this.name + '" /><input name="quote[data_centers][' + this.slug + '][slug]" type="hidden" value="' + this.slug + '" /></label></td><td class="center medium">' + (Math.round(this.distance * 100) / 100.0)  + '<div class="quiet">miles</div></td></tr>');
            tbody.prepend(row);
          }
        });
        loadingRow.remove();
        tbody.stripe();
      } else {
        results.html('No data centers could be found!');
      }
    }, 'json');
  });
});

jQuery.fn.extend({
  stripe: function() {
    this.find('tr.row').each(function(index) {
      $(this).removeClass('one two').addClass(index % 2 == 0 ? 'one' : 'two');
    });
  }
});