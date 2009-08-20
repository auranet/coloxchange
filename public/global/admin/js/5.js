var Autocompleter = new Class({
  choices:[],
  options:{ajaxOptions:{evalScripts:true},data:{},delay:400,itemTagName:"li",json:false,paramName:"value",useSpinner:true},
  timeout:false,
  selected:false,
  initialize:function(element,source,options) {
    this.element = $(element);
    this.unloadEvent = this.startUnload.bind(this),
    this.keypressEvent = this.keypress.bind(this),
    this.source = source;
    this.setOptions(options);
    if (element.getAttribute("rel")) {
      this.target = $(element.getAttribute("rel").split(";")[0]);
      this.attribute = element.getAttribute("rel").split(";")[1];
    }
    var position = this.element.getCoordinates();
    this.list = new Element("ul",{"class":"autocomplete-list",id:this.element.id+"_autocomplete_list",styles:{display:"none",left:position.left,top:position.top+position.height,width:position.width - 2}});
    this.list.injectInside(this.options.resultsIn || document.body);
    this.element.addEvent("blur",this.unloadEvent);
    this.element.addEvent(window.safari ? "keyup" : "keypress",this.keypressEvent);
  },
  keypress:function(event) {
    $clear(this.timeout);
    event = new Event(event);
    switch(event.key) {
      case "enter":
        event.stop();
        if (typeof(this.selected) != "undefined") this.selected.fireEvent("click");
      break;
      case "tab" || "esc":
        this.unload();
      break;
      case "down":
        event.stop();
        this.move(1);
      break;
      case "up":
        event.stop();
        this.move(-1);
      break;
      case "backspace":
        default:
        switch(event.code) {
          case 63233:
            event.stop();
            this.move(1);
          break;
          default:
            if (this.element.value + event.key == "") Controller.StopSpinner();
            else this.timeout = this.fetchChoices.bind(this).delay(this.options.delay);
          break;
        }
      break;
    }
  },
  fetchChoices:function() {
    if (this.options.resultsIn) this.options.resultsIn.addClass("loading");
    if (typeof(this.source) == "string") {
      if (this.element.value != "") {
        var data = {};
        data[this.options.paramName] = this.element.value;
        if (this.attribute) data["attribute"] = this.attribute;
        if (this.options.useSpinner) Controller.StartSpinner("Searching...");
        new Ajax(this.source,$merge({data:$merge(this.options.data,data),method:"post",onSuccess:function(){this.parse.delay(100,this);}.bind(this),update:this.list},this.options.ajaxOptions)).request();
      }
    } else {
      this.parse();
    }
  },
  parse:function() {
    if (this.options.resultsIn) this.options.resultsIn.removeClass("loading").addClass("has-results");
    if (typeof(newOptions) != "undefined") this.options = $merge(this.options,typeof(newOptions[this.element.name]) != "undefined" ? newOptions[this.element.name] : newOptions);
    this.choices = this.list.getElements(this.options.itemTagName);
    this.selected = false;
    this.choices.forEach(function(choice) {
      choice.injectInside(this.list);
      choice.addEvent("click",this.onSelect.bind(this));
    }.bind(this));
    if (this.choices.length > 0)
    this.show();
  },
  getValue:function(element) {
    while(element.tagName.toLowerCase() != this.options.itemTagName.toLowerCase())
    element = element.parentNode;
    if (this.options.getValue)
    return this.options.getValue(element);
    return element.innerHTML;
  },
  onSelect:function(event) {
    this.stopUnload();
    if (typeof(event) == "undefined") {
      var event = false;
      var clicked = this.selected;
    } else {
      var event = new Event(event);
      var clicked = event.target;
    }
    if (!this.options.onSelect || (this.options.onSelect && this.options.onSelect(clicked,this.element,event))) {
      // if (this.target) this.target.value = clicked.id.replace(/[^0-9]/ig,'');
      if (this.target) this.target.value = clicked.id;//.replace(/[^0-9]/ig,'');
      this.element.value = this.getValue(clicked);
    }
    this.unload();
  },
  move:function(amount) {
    if (this.selected && $defined(this.choices[this.choices.indexOf(this.selected)+amount])) {
      this.selected.removeClass("selected");
      this.selected = this.choices[this.choices.indexOf(this.selected)+amount];
    } else if (!this.selected) {
      this.selected = this.choices[0];
    }
    if (this.selected) this.selected.addClass("selected");
  },
  show:function() {
    this.list.setStyle("display","");
  },
  startUnload:function() {
    this.timeout = setTimeout(this.unload.bind(this),1000);
  },
  stopUnload:function() {
    $clear(this.timeout);
  },
  unload:function() {
    this.element.removeEvent("blur",this.unloadEvent);
    this.element.removeEvent("keypress",this.keypressEvent);
    this.list.remove();
  }
});
Autocompleter.implement(new Options);