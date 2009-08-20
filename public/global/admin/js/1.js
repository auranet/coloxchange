var App = {
  "a.calendar":function(element) {
    if (element.getAttribute("rel")) new Calendar(element);
  },
  "a.collapse::click":function(element,event) {
    event.stop();
    var collapse = $(element.getAttribute("rel"));
    if (collapse.isVisible()) {
      element.removeClass("expanded");
      collapse.hide();
    } else {
      element.addClass("expanded");
      collapse.show();
    }
  },
  "a.expand::click":function(element,event) {
    event.stop();
    element.blur();
    var expand = $(element.getAttribute("rel"));
    var start = element.findParent("div.sortable");
    var sortable = start.findParent("div.sortable");
    if (sortable) {
      while (sortable != start) {
        start = sortable;
        sortable = start.findParent("div.sortable");
      }
    }
    if (element.hasClass("expanded")) {
      element.removeClass("expanded");
      expand.setStyle("display","none");
      new Ajax(element.href + "&collapsed=true",{method:"get"}).request();
      Controller.Reorder.delay(10,null,[sortable]);
    } else {
      element.addClass("expanded");
      if (expand.innerHTML == "") {
        element.addClass("loading");
        Controller.StartSpinner();
        new Ajax(element.href,{method:"get",update:expand,onComplete:function(){element.removeClass("loading");Controller.Reorder.delay(10,null,[sortable]);}}).request();
      } else {
        Controller.Reorder(sortable);
      }
      expand.setStyle("display","");
    }
  },
  "a.external::click":function(element,event) {
    event.stop();
    window.open(element.href,element.getAttribute("rel"),'height=500,width=650,resizable=yes,scrollbars=yes');
  },
  "a.help-link::click, a.load-right::click":function(element,event) {
    event.stop();
    Controller.StartSpinner();
    new Ajax(element.href,{method:"get",update:$("right")}).request();
  },
  "a.load::click":function(element,event) {
    event.stop();
    Controller.StartSpinner();
    var request = new Ajax(element.href,{method:"get"});
    if (element.getAttribute("rel")) request.options["update"] = $(element.getAttribute("rel"));
    request.request();
  },
  "a.new":function(element) {
    element.target = "_new";
  },
  "a.remove::click":function(element,event) {
    event.stop();
    var rel = element.getAttribute("rel");
    if (rel.contains("parentNode")) {
      var remove = element;
      for (var i = 0; i < rel.split(".").length; i++) remove = remove.getParent();
    } else {
      var remove = $(rel);
    }
    remove.remove();
  },
  "a.right-expand::click":function(element,event) {
    event.stop();
    element.blur();
    var expand = $(element.getAttribute("rel"));
    if (element.hasClass("expanded")) {
      element.removeClass("expanded");
      expand.setStyle("display","none");
    } else {
      element.addClass("expanded");
      expand.setStyle("display","");
    }
    new Ajax(element.href + "?collapsed=" + (element.hasClass("expanded") ? "no" : "yes"),{method:"get"}).request();
  },
  "a.toggle::click":function(element,event) {
    event.stop();
    var toggle = $(element.getAttribute("rel"));
    if (toggle) toggle.setStyle("display",toggle.getStyle("display") == "none" ? "" : "none");
  },
  "a.unlock::click":function(element,event) {
    event.stop();
    var lock = $(element.getAttribute("rel"));
    if (element.hasClass("unlocked")) {
      element.removeClass("unlocked");
      lock.disabled = true;
    } else {
      element.addClass("unlocked");
      lock.disabled = false;
      lock.focus();
    }
  },
  "div.sortable":function(element) {
    new Sortables(element,{handles:element.getChildren().map(function(sorted,i){return sorted.getFirst().getFirst().getFirst().getChildren().getLast()}),onDragStart:function(element,ghost) {
      element.getFirst().getFirst().getFirst().addClass("dragging");
      ghost.setStyles({display:"none",width:element.getSize().size.x,opacity:0.5}).addClass("ghost").setStyle("display","");
    },onDragComplete:function(element,ghost) {
      element.getFirst().getFirst().getFirst().removeClass("dragging");
      ghost.remove();
      this.trash.remove();
    },onComplete:function(element,event) {
      var sortable = element.findParent("div.sortable");
      var params = sortable.getElements("div.sorted").map(function(item){return "records[]=" + item.id.replace(/[^0-9]/ig,"");}).join("&");
      Controller.StartSpinner("Saving...");
      new Ajax(AdminUrl + "/" + sortable.id.replace(/[^a-z_]/ig,"").replace(/_$/g,"") + "/reorder?" + params,{method:"get"}).request();
      Controller.Reorder(sortable);
    }});
  },
  "form.xhr::submit":function(element,event) {
    var files = element.getElements("input[type=file]");
    if (files.some(function(input) { return input.value != ""; })) {
      var iframe = new Element("iframe",{name:"xhr_file"}).injectInside(element).setStyle("display","none");
      element.target = iframe.name;
      iframe.addEvent("load",function(){alert(iframe.document.body.innerHTML);});
    } else {
      Controller.StartSpinner("Saving...");
      new Ajax(element.action,{method:element.method,update:element.parentNode}).request(element.toQueryString);
      event.stop();
    }
  },
  "input.complete":function(element) {
    if (typeof(Autocompleter) == "undefined") new Asset.javascript("/global/admin/js/5.js",{onload:function(){App["input.complete"].delay(100,null,[element])}});
  },
  "input.complete::focus":function(element) {
    new Autocompleter(element,element.getAttribute("alt"));
  },
  "input.decimal::keypress":function(element,event) {
    if (!event.key.match(/([0-9]|backspace|delete|up|down|left|right|enter|tab)/ig)) event.stop();
  },
  "input.integer::keypress":function(element,event) {
    if (!event.key.match(/([0-9]|backspace|delete|up|down|left|right|enter|tab)/ig)) event.stop();
  },
  "input.option::click":function(element) {
    if (element.type.toLowerCase() == "radio") {
      $A(document.getElementsByName(element.name)).forEach(function(input) {
        input = $(input);
        var options = $(input.id + "_options");
        if (options) {
          if (input == element) options.show();
          else options.hide();
        }
      });
    } else if (element.type.toLowerCase() == "checkbox") {
      var options = $(element.id + "_options");
      options.setStyle("display",options.getStyle("display") == "none" ? "" : "none");
    }
  },
  "input.replace":function(element) {
    var value = element.value;
    element.addEvent("focus",function(){
      if (element.value == value) element.value = "";
      element.addClass("focused");
    });
    element.addEvent("blur",function(){
      if (element.value == "") element.value = value;
      element.removeClass("focused");
    });
  },
  "input.reveal::click,input.unreveal::click":function(element) {
    var show = element.hasClass("unreveal") ? !element.checked : element.checked;
    var hide_div = $(element.getAttribute("rel") + "_hide");
    var show_div = $(element.getAttribute("rel"));
    if (hide_div) hide_div.setStyle("display",show ? "none" : "");
    if (show_div) show_div.setStyle("display",show ? "" : "none");
  },
  "input.search":function(element) {
    if (window.webkit) element.setProperty("type","search");
    if (typeof(Autocompleter) == "undefined") new Asset.javascript("/global/admin/js/5.js");
  },
  "input.search::focus":function(element) {
    new Autocompleter(element,element.getAttribute("alt"),{onSelect:function(clicked,input,event){
      input.value = "";
      window.location = input.alt.replace("/search","/" + clicked.id);
    },resultsIn:element.getParent().getElement("div.search-results"),useSpinner:false});
  },
  "input.select-all::click":function(element) {
    $(element.form).getElements("td input").forEach(function(input) {input.checked = element.checked;});
  },
  "input.slug":function(element) {
    var monitor = $(element.getAttribute("rel"));
    monitor.addEvent("keyup",function() {
      var slug = monitor.value.toLowerCase().replace(/(_| )/ig,"-").replace(/-{2,}/ig,"-").replace(/(^-|-$)/ig,"").replace(/[^a-z0-9-]/ig,"").replace(/(^-{1,}$|$-{1,}^|-{2,})/ig,"");
      if (slug.length > 40)
      slug = slug.substring(0,slug.substring(0,40).lastIndexOf("-"));
      element.value = slug;
    });
  },
  "table.display tr.row1::click, table.display tr.row2::click":function(element,event) {
    if (event.target.tagName != "A" && event.target.tagName != "INPUT" && event.target.className != "handle") {
      event.stop();
      var checkbox = element.getElement("input[type=checkbox]");
      if (checkbox) checkbox.checked = !checkbox.checked;
    }
  }
};

var Controller = {
  Reorder:function(element,tagname) {
    var i = 0;
    if (!tagname) tagname = "tr";
    element.getElements(tagname).forEach(function(row) {
      if (row.getSize().size.y > 0 && (row.hasClass("row1") || row.hasClass("row2"))) row.removeClass("row1").removeClass("row2").addClass("row" + (i++%2+1));
    });
  },
  StartSpinner:function(text) {
    if (typeof(text) == "undefined") text = "Loading...";
    var spinner = $("spinner")
    // if (spinner) spinner.setHTML(text).setStyle("opacity",1).setStyle("display","");
    if (spinner) spinner.setStyle("display","");
  },
  StopSpinner:function() {
    var spinner = $("spinner")
    // if (spinner) var fade = function(){spinner.effect("opacity",{duration:200}).start(1,0)}.delay(500);
    if (spinner) var fade = function(){spinner.setStyle("display","none");}.delay(500);
  }
}

var Calendar = new Class({
  initialize:function(link,target) {
    this.link = $(link);
    this.target = this.link.getAttribute("rel");
    this.calendar = new Element("div",{"class":"calendar-container"});
    this.table = new Element("table").injectInside(this.calendar);
    this.headerRow = new Element("thead").injectInside(this.table);
    this.titleRow = new Element("tr").injectInside(this.headerRow);
    this.prevMonth = new Element("a").setHTML("&laquo;").injectInside(new Element("th",{"class":"calendar-button-cell"}).injectInside(this.titleRow));
    this.tableHeader = new Element("th",{"class":"calendar-header",colspan:5}).injectInside(this.titleRow);
    this.nextMonth = new Element("a").setHTML("&raquo;").injectInside(new Element("th",{"class":"calendar-button-cell"}).injectInside(this.titleRow));
    this.prevMonth.addEvent("click",this.go.bind(this,[-1]));
    this.nextMonth.addEvent("click",this.go.bind(this,[1]));
    var dayRow = new Element("tr").injectInside(this.headerRow);
    ["S","M","T","W","Th","F","S"].forEach(function(day){new Element("th",{"class":"calendar-day-header"}).setHTML(day).injectInside(dayRow);});
    this.tbody = new Element("tbody").injectInside(this.table);
    this.monthSelect = $(this.target + "_2i");
    this.daySelect = $(this.target + "_3i");
    this.yearSelect = $(this.target + "_1i");
    var years = $A(this.yearSelect.options).map(function(option) { return option.value.toInt(); });
    this.minYear = Math.min.apply(Math,years);
    this.maxYear = Math.max.apply(Math,years);
    this.unloadEvent = function(event) {
      var event = new Event(event);
      if (event.type == "keypress") {
        if (event.key == "esc") {
          this.unload();
          $(document.body).addEvents("keypress",this.oldBodyEvents);
        }
      } else if (event.type == "click") {
        var target = $(event.target);
        if (target != this.link && !target.getAncestors().contains(this.calendar)) this.unload();
      } 
    }.bind(this);
    this.link.addEvent("click",this.showCalendar.bind(this));
  },
  buildMonth:function(direction,from) {
    var month = from.getMonth() + direction;
    var year = from.getFullYear();
    if (month == -1) {
      month = 11;
      year -= 1;
    } else if (month == 12) {
      month = 0;
      year += 1;
    }
    return new Date(year,month,1);
  },
  getMonthName:function() {
    return ["January","February","March","April","May","June","July","August","September","October","November","December"][this.month.getMonth()];
  },
  go:function(direction) {
    if (direction != 0) this.month = this.buildMonth(direction,this.month);
    this.tableHeader.setHTML(this.getMonthName() + " " + this.month.getFullYear());
    var offset = this.month.getDay();
    var rows = [new Element("tr")];
    var rowIndex = 0;
    var nextMonth = this.buildMonth(1,this.month);
    var prevMonth = this.buildMonth(-1,this.month);
    var noNextMonth,noPrevMonth;
    if (nextMonth.getFullYear() > this.maxYear) {
      this.nextMonth.setStyle("display","none");
      noNextMonth = true;
    } else  {
      this.nextMonth.setStyle("display","");
    }
    if (prevMonth.getFullYear() < this.minYear) {
      this.prevMonth.setStyle("display","none");
      noPrevMonth = true;
    } else {
      this.prevMonth.setStyle("display","");
    }
    var prevMonthDays = new Date(prevMonth.getFullYear(),prevMonth.getMonth()+1,0).getDate();
    for (var i = offset-1; i >= 0; i--) {
      var day = prevMonthDays - i;
      var dayCell = new Element("td",{"class":"calendar-day grey"}).setHTML(day).injectInside(rows[0]);
      if (!noPrevMonth) dayCell.addEvent("click",this.select.bind(this,[prevMonth.getFullYear(),prevMonth.getMonth(),day]));
    }
    var days = new Date(this.month.getFullYear(),this.month.getMonth()+1,0).getDate();
    var day = 0;
    while (day <= days) {
      for (var i = offset; i <= 6; i++) {
        if (day++ < days) {
          var dayCell = new Element("td",{"class":"calendar-day" + (this.month.getFullYear() == this.date.getFullYear() && this.month.getMonth() == this.date.getMonth() && day == this.date.getDate() ? " active-day" : "")}).setHTML(day).injectInside(rows[rowIndex]);
          dayCell.addEvent("click",this.select.bind(this,[this.month.getFullYear(),this.month.getMonth(),day]));
        }
        offset = 0;
      }
      if (day < days) {
        rowIndex++;
        rows[rowIndex] = new Element("tr");
      }
    }
    var filler = 7 - rows[rowIndex].getChildren().length;
    for (var i = 1; i <= filler; i++) {
      var dayCell = new Element("td",{"class":"calendar-day grey"}).setHTML(i).injectInside(rows[rowIndex]);
      if (!noNextMonth) dayCell.addEvent("click",this.select.bind(this,[nextMonth.getFullYear(),nextMonth.getMonth(),i]));
    }
    this.tbody.getChildren().forEach(function(row){ row.remove(); });
    this.headerRow.injectInside(this.table);
    rows.forEach(function(row) {
      row.injectInside(this.tbody);
    }.bind(this));
  },
  select:function(year,month,day) {
    this.date = new Date(year,month,day);
    year = year.toString();
    this.setSelectValue(this.yearSelect,year);
    this.setSelectValue(this.monthSelect,month+1);
    this.setSelectValue(this.daySelect,day);
    this.unload();
  },
  setSelectValue:function(select,value) {
    var index;
    value = value.toString();
    $A(select.options).forEach(function(option,i) {
      if (option.value == value) select.selectedIndex = i;
      if (select == this.month) alert(i + ": " + option.value + " == " + value + " ? " + (option.value == value));
    });
  },
  showCalendar:function(event) {
    new Event(event).stop();
    var body = $(document.body);
    this.oldBodyEvents = body.removeEvents("keypress");
    body.addEvent("click",this.unloadEvent);
    body.addEvent("keypress",this.unloadEvent);
    var coordinates = this.link.getCoordinates();
    this.date = new Date(this.yearSelect.value.toInt(),this.monthSelect.value.toInt()-1,this.daySelect.value.toInt());
    this.month = new Date(this.date.getFullYear(),this.date.getMonth(),1);
    this.go(0);
    this.calendar.setStyles({top:coordinates.top,left:coordinates.left}).injectInside(document.body);
  },
  unload:function() {
    $(document.body).removeEvent("click",this.unloadEvent);
    this.calendar.effects({duration:100,onComplete:function(){this.calendar.setStyle("opacity",1).remove();}.bind(this)}).start({opacity:0});
  }
});