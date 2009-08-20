var Editors = {};
Object.extend(App,{
  "a.rollover::mouseover":function(element,event) {
    var img = element.getElement("img");
    img.src = img.src.replace(/\.(.{2,4})$/,function(original,extension){
      return "-hover." + extension;
    });
  },
  "a.rollover::mouseout":function(element,event) {
    var img = element.getElement("img");
    img.src = img.src.replace("-hover.",".");
  },
  "form.edit-form":function(element) {
    if (!window.ie) {
      var formElements = element.getElementsBySelector("select,input,textarea");
      i = 0;
      while(formElements[i] && formElements[i].getAttribute("type") == "hidden") i++;
      if (formElements[i]) formElements[i].focus();
    }
    var body = $(document.body);
    var cancelFunction = function(){window.location = $("admin-form-cancel-button").href}
    body.addEvent("keypress",function(event){
      event = new Event(event);
      if (event.key == "s" && event.control) (event.alt ? $("admin-form-save-and-add-another-button") : $("admin-form-save-and-return-button")).click();
      else if (event.key == "esc") cancelFunction.delay(100);

    });
  },
  // "div.photo-browser": function(element) {
  //   new Ajax(AdminUrl + "/editor/photos",{update:element}).request();
  // },
  "textarea.editor":function(element) {
    var options = {styleSheet:"/global/admin/css/5.css"};
    if (element.getAttribute("rel")) {
      options.mode = element.getAttribute("rel");
      options.filter_name = element.name.substring(0,element.name.length - 1) + "_filter]"
    } else {
      options.modes = ["HTML","WYSIWYG"]
      options.filter_name = "";
    }
    
    Editors[element.id] = new Editor(element,options);
  }
});

var Editor = new Class({
  options:{buttons:["h1","h2","h3","divider","bold","italic","divider","bulleted-list","numbered-list","divider","hyperlink","image","mode"],imageRoot:"/global/admin/images/editor/",mode:"wysiwyg",modes:["HTML","Textile","Markdown","WYSIWYG"],styleSheet:"/css/editor.css",toolbarHeight:12,timeoutInterval:700},
  toolbox:false,
  initialize:function(element,options) {
    this.text = $(element);
    if (Media) this.options.buttons.push("video");
    this.setOptions(options);
    this.mode = this.options.mode || "wysiwyg";
    this.container = new Element("div",{"class":"editor"});
    this.toolbar = new Element("div",{"class":"editor-toolbar"});
    this.options.buttons.forEach(function(button) {
      if (button == "mode") {
        var image = new Element("select",{"class":"float-right",name:this.options.filter_name,styles:{fontSize:"9px",padding:0,margin:"1px 2px 0 0"}}).addEvent("change",this.changeMode.bind(this));
        this.options.modes.forEach(function(mode){
          var option = new Element("option",{value:mode.toLowerCase()}).setHTML(mode).injectInside(image);
          if (this.mode == mode.toLowerCase()) option.selected = true;
        }.bind(this));
        image.injectTop(this.toolbar);
      } else {
        var image = new Element("img",{src:this.options.imageRoot+button+".gif"}).injectInside(this.toolbar);
        var alt = button == "divider" ? "|" : button.replace("-"," ").capitalize();
        if (button != "divider") image.setProperties({alt:alt,title:alt}).setStyle("opacity",0.5).addEvent('mouseover',function(){this.setStyle("opacity",1);}).addEvent('mouseout',function(){this.setStyle("opacity",0.5);}).addEvent('click',this.buttonClick.bind(this))
        else image.setProperty("alt","|").setStyle("cursor","default");
      }
    }.bind(this));
    this.toolbar.injectInside(this.container);
    this.text.replaceWith(this.container);
    this.text.injectInside(this.container);
    this.coordinates = this.text.getCoordinates();
    this.minHeight = this.coordinates.height;
    this.maxHeight = window.getHeight()-65;
    // Configure WYSIWYG editing, if enabled
    this.wysiwyg = this.options.modes.contains("WYSIWYG");
    if (this.wysiwyg) this.html = new Element("iframe",{"class":"editor-iframe",frameBorder:0,styles:{height:this.coordinates.height,visibility:"hidden"}}).injectInside(this.container);
    this.dragHandle = new Element("div",{"class":"editor-resize"}).injectInside(this.container);
    this.dragHandle.addEvent("dblclick",this.autoResizeHTML.bind(this));
    var selectors = ["imageForm","hyperlinkForm"];
    if (Media) selectors.push("videoForm");
    selectors.forEach(function(toolbox) {
      this[toolbox] = new Element("div",{"class":"editor-toolbox",id:this.text.id + "_" + toolbox,styles:{display:"none"}});
      this[toolbox].injectInside(document.body);
    }.bind(this));
    if (this.wysiwyg) this.startWYSIWYG();
    this.text.setStyle("display",this.mode == "wysiwyg" ? "none" : "").makeResizable({handle:this.dragHandle,modifiers:{x:false,y:"height"},limit:{y:[this.minHeight,this.maxHeight]}});
  },
  addText:function(text,select,beforeSelect,selectionLength) {
    if (this.mode == "wysiwyg") {
      var container = new Element("div").setHTML(text);
      var element = container.firstChild;
      if (this.html.contentWindow.document.selection) this.html.contentWindow.document.selection.createRange().pasteHTML(container.innerHTML);
      else {
        var selection = this.html.contentWindow.getSelection();
        var range = selection.getRangeAt(0);
        selection.removeAllRanges();
        range.deleteContents();
        var content = range.startContainer;
        var position = range.startOffset;
        range = this.html.contentWindow.document.createRange();
        if (element.nodeType == 3) {
          // Text inside text
          alert("Error: Please contact Sasser Interactive");
        } else {
          if (content.tagName == "HTML") {
            if (this.html.contentWindow.document.body.firstChild == null) this.writeWYSIWYG("<br />");
            content = this.html.contentWindow.document.body.firstChild;
          }
          if (content.nodeType == 3) {
            var text = content.nodeValue;
            var startText = text.substr(0,position);
            var endText = text.substr(position);
            var start = document.createTextNode(startText);
            var end = document.createTextNode(endText);
            content.parentNode.insertBefore(end,content);
            content.parentNode.insertBefore(element,end);
            content.parentNode.insertBefore(start,element);
            content.parentNode.removeChild(content);
            range.setEnd(end,0);
            range.setStart(end,0);
          } else {
            if (content.childNodes[position].nodeType == 3) element.injectTop(content);
            else element.injectBefore(content.childNodes[position]);
          }
        }
      }
      this.saveWYSIWYG();
    } else {
      var selectedTextPosition = this.text.getSelectionStart();
      this.text.insertAtCursor(text,false);
      if (select) this.text.selectRange(selectedTextPosition + beforeSelect,selectedTextPosition + beforeSelect + selectionLength);
      else this.text.setCaretPosition(selectedTextPosition + beforeSelect);
    }
  },
  autoResizeHTML:function() {
    var element = (this.mode == "wysiwyg" ? this.html : this.text);
    var height = element.getSize().size.y < this.maxHeight ? this.maxHeight : this.minHeight;
    element.effect("height",{onComplete:function() {new Fx.Scroll(window,{onComplete:function(){
      (this.mode == "wysiwyg" ? this.text : this.html).setStyle("height",height);
    }.bind(this)}).toElement(this.container);}.bind(this)}).start(height);
  },
  buttonClick:function(event) {
    event = new Event(event).stop();
    var element = event.target;
    var command = element.src.substring(element.src.lastIndexOf("/")+1,element.src.lastIndexOf(".gif"));
    if (command == "hyperlink" || command == "image" || command == "video") {
      if (this.toolbox != this[command + "Form"]) new Ajax(AdminUrl + "/editor/" + command,{method:"get",onComplete:this.sizeAndAnimateIn.bind(this,[command]),update:this[command + "Form"],url:AdminUrl + "/editor/" + command}).request();
    } else if (this.mode != "wysiwyg") {
      var block = this.getBlock(command);
      var blockClear = this.mode == "html" && (command == "bulleted-list" || command == "numbered-list");
      var subBlock = this.getSubBlock(command);
      if (typeof(subBlock) == "undefined" || subBlock == "<>" || subBlock == "" || subBlock == "<undefined>") subBlock = false;
      var selectedText = this.text.getSelectedText();
      var selectionLenth = selectedText.length;
      var select = selectionLenth > 0;
      var wrapSubBlock = this.wrapSubBlock(command);
      if (subBlock) selectedText = selectedText.split("\n").map(function(subBlockItem){return (blockClear ? "  " : "") + subBlock+subBlockItem+(wrapSubBlock ? this.mode == "html" ? subBlock.replace("<","</") : subBlock : "");}.bind(this)).join("\n");
      selectedText = block+(blockClear ? "\n" : "")+selectedText;
      if (this.wrapBlock(command)) selectedText +=  (blockClear ? "\n" : "") + (this.mode == "html" ? block.replace("<","</") : block);
      this.addText(selectedText,select,block.length + (subBlock ? subBlock.length : 0),selectionLenth);
    } else {
      if (command == "numbered-list" || command == "bulleted-list") this.html.contentWindow.document.execCommand("Insert" + (command == "numbered-list" ? "O" : "Uno") + "rderedList",false,null);
      else this.html.contentWindow.document.execCommand((command == "bold" || command == "italic" ? command.charAt(0).toUpperCase() + command.substring(1,command.length) : "FormatBlock"),false,(command == "bold" || command == "italic" ? null : this.getBlock(command)));
      this.saveWYSIWYG();
    }
  },
  changeMode:function(event) {
    var oldMode = this.mode;
    event = new Event(event);
    this.mode = event.target.value;
    if (this.mode == "wysiwyg") this.showWYSIWYG();
    else if (oldMode == "wysiwyg") this.hideWYSIWYG();
  },
  getBlock:function(command) {
    if (this.mode == "html" || this.mode == "wysiwyg") return "<"+{h1:"h1",h2:"h2",h3:"h3",bold:"b",italic:"i","bulleted-list":"ul","numbered-list":"ol"}[command]+">";
    else if (this.mode == "textile") return {h1:"h1. ",h2:"h2. ",h3:"h3. ",bold:"*",italic:"_","bulleted-list":"","numbered-list":""}[command];
    else if (this.mode == "markdown") return {h1:"# ",h2:"## ",h3:"### ",bold:"**",italic:"*","bulleted-list":"","numbered-list":""}[command];
  },
  getSelectedText:function() {
    if (this.mode == "wysiwyg") return this.html.contentWindow.getSelection().getRangeAt(0).toString();
    else return this.text.getSelectedText();
  },
  getSubBlock:function(command) {
    if (this.mode == "html" || this.mode == "wysiwyg") return "<"+{"bulleted-list":"li","numbered-list":"li"}[command]+">";
    else if (this.mode == "textile") return {"bulleted-list":"* ","numbered-list":"# "}[command];
    else if (this.mode == "markdown") return {"bulleted-list":"- ","numbered-list":"n. "}[command];
  },
  hideToolbox:function() {
    var hide = function(){this.toolbox.setStyle("display","none"); this.toolbox = false;}.bind(this);
    hide.delay(100);
  },
  hideWYSIWYG:function() {
    this.saveWYSIWYG();
    this.html.setStyle("display","none");
    this.text.setStyle("display","");
  },
  insertImage:function(photo) {
    var ext = photo.src.substr(photo.src.lastIndexOf("."),photo.src.length);
    photo.src = photo.src.replace(ext,"-" + photo.size + ext);
    var alt = this.getSelectedText() && this.getSelectedText() != "" ? this.getSelectedText() : photo.alt;
    var image = '<img alt="' + alt + '" class="' + photo["class"] + '" src="' + photo.src + '" />'
    this.addText.bind(this,[image,this.getSelectedText().length > 0,0,image.length]).call();
    this.hideToolbox();
  },
  keypressWYSIWYG:function(event) {
    event = new Event(event);
    $clear(this.timeout);
    var dataSize = this.html.contentWindow.document.body.innerHTML.stripTags().length;
    // alert(this.wysiwygSize);
    this.timeout = this.saveWYSIWYG.delay(this.options.timeoutInterval,this);
  },
  listenWYSIWYG:function() {
    // Hack-ish workaround for iFrame document being unable to accept addEvent directly
    Element.addListener(this.html.contentWindow.document,"keypress",this.keypressWYSIWYG.bind(this));
    // Element.addListener(this.html.contentWindow.document,"input",this.keypressWYSIWYG.bind(this));
    this.html.makeResizable({handle:this.dragHandle,modifiers:{x:false,y:"height"},limit:{y:[this.minHeight,this.maxHeight]}});
  },
  loadHyperlinkForm:function() {
    $("link_label").value = this.getSelectedText();
    var submitEvent = function(event) {
      var event = new Event(event).stop();
      // var url = $("point_to_page").checked ? $("page_url").value : $("point_to_action").checked ? $("action_url").value : "http://" + $("text_url").value;
      var url = $("point_to_page").checked ? $("page_url").value : $("text_url").value;
      var link;
      var value = $("link_label").value;
      if (this.mode == "wysiwyg") {
        var form = $("link_label").form;
        var link_to = $A(form["point_to"]).filter(function(input){return input.checked;})[0].value;
        var span = new Element("span");
        var link = new Element("a",{href:(link_to == "page" ? $("page_url").value : ("http://" + $("text_url").value))}).setHTML($("link_label").value).injectInside(span);
        this.addText(span.innerHTML);
      } else {
        if (this.mode == "html") {
          link = '<a href="' + url + '">' + value + "</a>";
          var beforeSelect = 11;
        } else if (this.mode == "markdown") {
          link = "[" + value + "](" + url + ")";
          var beforeSelect = 1;
        } else if (this.mode == "textile") {
          link = '"' + value + '":' + url;
          var beforeSelect = 1;
        }
        this.addText.bind(this,[link,value.length > 0,this.mode == "html" ? beforeSelect + url.length : beforeSelect,value.length]).call();
      }
      this.hideToolbox();
    }.bind(this);
    this.toolbox.getElement("button").addEvent("click",submitEvent);
    this.toolbox.getElement("form").addEvent("submit",submitEvent);
  },
  loadImageForm:function() {
    var submitEvent = function(event) {
      var event = new Event(event).stop();
      var form = $(event.target);
      var alignment = $A(form["photo[align]"]).filter(function(input){return input.checked;})[0].value;
      var photo = {"class":($("photo_border").checked ? "photo" : "") + (alignment == "none" ? "" : (" float-" + alignment)),"size":$A(form["photo[size]"]).filter(function(input){return input.checked;})[0].value};
      var photoField = $("inline-photo-upload-field").form.instance_path.value;
      if (photoField != "" && !photoField.match(/^[0-9]+$/)) {
        var iframe = new Element("iframe",{id:"photo_form_frame",name:"photo_form_iframe"}).injectInside(form).setStyle("display","none");
        iframe.addEvent("load",function() {
          var processIframe = function() {
            var newPhoto = Json.evaluate(iframe.contentWindow.document.body.innerHTML);
            if (newPhoto.errors && newPhoto.errors.length > 0) {
            } else {
              photo.alt = newPhoto.caption;
              photo.src = newPhoto.url;
              this.insertImage(photo);
            }
          }.bind(this);
          processIframe.delay(100);
        }.bind(this));
        form.target = iframe.name;
        form.action += "?json=yes";
        form.submit();
      } else {
        event.stop();
        var selected = $(form["photo[photo_id]"].tagName ? form["photo[photo_id]"] : $A(form["photo[photo_id]"]).filter(function(input){return input.checked;})[0]);
        if (selected) {
          selected = selected.getParent().getNext().getElement("img");
          photo.alt = selected.alt;
          photo.src = selected.src.replace("-admin_thumb.",".");
          this.insertImage(photo);
        } else alert("Please select a photo first.")
      }
    }.bind(this);
    // this.toolbox.getElement("button").addEvent("click",submitEvent);
    this.toolbox.getElement("form").addEvent("submit",submitEvent);
  },
  loadVideoForm:function() {
    var submitEvent = function(event) {
      var event = new Event(event).stop();
      var value = this.getSelectedText();
      var video = $("video_src").value;
      this.addText.bind(this,[video,value.length > 0,0,video.length]).call();
      this.hideToolbox();
    }.bind(this);
    this.toolbox.getElement("button").addEvent("click",submitEvent);
    this.toolbox.getElement("form").addEvent("submit",submitEvent);
  },
  saveWYSIWYG:function() {
    var data = this.html.contentWindow.document.body.innerHTML.stripTags();
    this.wysiwygSize = data.length;
    this.text.value = data;
  },
  setFocus:function() {
    if (this.mode == "wysiwyg") this.html.document.body.focus();
    else this.text.focus();
  },
  sizeAndAnimateIn:function(element) {
    var options = {duration:200,transition:Fx.Transitions.Sine.easeInOut};
    var inForm = this[element + "Form"];
    if (!inForm.getElement(".shadow")) new Element("div",{"class":"shadow",styles:{opacity:0.75,top:0}}).injectTop(inForm);
    inForm.setStyles({display:"block",opacity:0});
    var browser = inForm.getElement(".photo-browser");
    if (browser) browser.setStyle("width",browser.setStyle("display","none").getParent().getCoordinates().width).setStyle("display","");
    var coordinates = inForm.getCoordinates();
    if (coordinates.width > this.coordinates.width) inForm.setStyle("width",coordinates.width = (this.coordinates.width - 40));
    inForm.setStyle("left",this.coordinates.left + (this.coordinates.width / 2) - (coordinates.width / 2) - 10);
    var inEffect = inForm.effects(options);
    var inOptions = {top:[this.coordinates.top,this.coordinates.top+2],opacity:[0,1]};
    if (this.toolbox) this.toolbox.effects($merge(options,{onComplete:function(){inEffect.start(inOptions);}})).start({opacity:0});
    else inEffect.start(inOptions);
    this.toolbox = inForm;
    this.toolbox.getElement("a.cancel").addEvent("click",function(event){new Event(event).stop(); this.toolbox.effects($merge(options,{onComplete:function(){this.toolbox.setStyle("display","none"); this.toolbox = false;}.bind(this)})).start({opacity:0});}.bind(this));
    this["load" + element.capitalize() + "Form"].bind(this).call();
  },
  showWYSIWYG:function() {
    this.text.setStyle("display","none");
    this.html.setStyle("display","");
    this.startWYSIWYG();
  },
  startWYSIWYG:function() {
    try {this.html.contentWindow.document.designMode = "on";} catch(e) {this.startWYSIWYG.delay(250,this);return false;}
    this.listenWYSIWYG.delay(100,this);;
    this.writeWYSIWYG(this.text.value);
    this.html.setStyles({display:this.mode == "wysiwyg" ? "" : "none",visibility:""});
  },
  wrapBlock:function(command) {
    if (this.mode == "html") return true;
    else return command == "bold" || command == "italic";
  },
  wrapSubBlock:function(command) {
    if (this.mode == "html") return true;
    else false;
  },
  writeWYSIWYG:function(data) {
    if (data == "") data = "<br />";
    data = '<html><head><link href="/css/global.css" rel="stylesheet" type="text/css" /><link href="'+this.options.styleSheet+'" rel="stylesheet" type="text/css" /></head><body>'+data+'</body></html>';
    this.html.contentWindow.document.open();
    this.html.contentWindow.document.write(data);
    this.html.contentWindow.document.close();
  }
});
Editor.implement(new Options);

Element.extend({
  getTextInRange: function(start, end) {
    return this.getValue().substring(start, end);
  },
  getSelectedText: function() {
    if(window.ie) return document.selection.createRange().text;
    return this.getValue().substring(this.getSelectionStart(), this.getSelectionEnd());
  },
  getSelectionStart: function() {
    if(window.ie) {
      this.focus();
      var range = document.selection.createRange();
      if (range.compareEndPoints("StartToEnd", range) != 0) range.collapse(true);
      return range.getBookmark().charCodeAt(2) - 2;
    }
    return this.selectionStart;
  },
  getSelectionEnd: function() {
    if (window.ie) {
      var range = document.selection.createRange();
      if (range.compareEndPoints("StartToEnd", range) != 0) range.collapse(false);
      return range.getBookmark().charCodeAt(2) - 2;
    }
    return this.selectionEnd;
  },
  getSelectedRange: function() {
    return {start:this.getSelectionStart(),end:this.getSelectionEnd()};
  },
  setCaretPosition: function(pos) {
    if (pos == 'end') pos = this.getValue().length;
    this.selectRange(pos,pos);
    return this;
  },
  getCaretPosition: function() {
    return this.getSelectedRange().start;
  },
  selectRange: function(start, end) {
    this.focus();
    if(window.ie) {
      var range = this.createTextRange();
      range.collapse(true);
      range.moveStart('character', start);
      range.moveEnd('character', end - start);
      range.select();
      return this;
    }
    this.setSelectionRange(start, end);
    return this;
  },
  insertAtCursor: function(value, select) {
    var start = this.getSelectionStart();
    var end = this.getSelectionEnd();
    this.value = this.getValue().substring(0, start) + value + this.getValue().substring(end, this.getValue().length);
    if($pick(select, true)) this.selectRange(start, start + value.length);
    else this.setCaretPosition(start + value.length);
    return this;
  },
  insertAroundCursor:function(options,select) {
    options = $merge({before: '',defaultMiddle: 'SOMETHING HERE', after: '' }, options);
    value = this.getSelectedText() || options.defaultMiddle;
    var start = this.getSelectionStart();
    var end = this.getSelectionEnd();
    if(start == end) {
      var text = this.getValue();
      this.value = text.substring(0, start) + options.before + value + options.after + text.substring(end, text.length);
      this.selectRange(start + options.before.length, end + options.before.length + value.length);
      text = false;
    } else {
      text = this.getValue().substring(start, end);
      this.value = this.getValue().substring(0, start) + options.before + text + options.after + this.getValue().substring(end, this.getValue().length);
      var selStart = start + options.before.length;
      if($pick(select, true)) this.selectRange(selStart, selStart + text.length);
      else this.setCaretPosition(selStart + text.length);
    }
    return this;
  }
});

// String markup cleaning
String.prototype.stripTags = function() {
  var string = this.replace(/<[^> ]*/ig, function(match){return match.toLowerCase();}).replace(/<[^>]*>/ig, function(match){match = match.replace(/ [^=]+=/ig, function(match2){return match2.toLowerCase();}); return match;}).replace(/<[^>]*>/ig, function(match){match = match.replace(/( [^=]+=)([^"][^ >]*)/ig, "$1\"$2\""); return match;}).replace(/^\s+/, "").replace(/\s+$/, "").replace(/<br>/ig, "<br />").replace(/<br \/>\s*<\/(h1|h2|h3|h4|h5|h6|li|p)/ig, "</$1").replace(/(<img [^>]+[^\/])>/ig, "$1 />");//.replace(/(<[^\/]>|<[^\/][^>]*[^\/]>)\s*<\/[^>]*>/ig, "");
  // if (window.ie) string = string.replace(/<p>(.+)<\/p>/ig,"$1<br />").replace(/&nbsp;<br \/>/ig,"<br />").replace(/<strong>(.+)<\/strong>/ig,"<b>$1</b>").replace(/<strong><\/strong>/ig,"");
  if (window.ie) string = string.replace(/&nbsp;<br \/>/ig,"<br />").replace(/<strong>(.+)<\/strong>/ig,"<b>$1</b>").replace(/<strong><\/strong>/ig,"");
  else if (window.webkit) {
    string = string.replace(/<div>([^(<\/div>)]+)<\/div>/ig,"<br />$1").replace(/<DIV><BR class="([^"]+)-block-placeholder"><\/DIV>/ig,'<br />');
    while(string.match(/<span class="Apple-style-span" style="([^"]+)">(.+)<\/span>/)) {
      string = string.replace(/<span class="Apple-style-span" style="([^"]+)">(.+)<\/span>/g,function() {
        switch(arguments[1]) {
          case "font-weight: bold;":
          return "<b>" + arguments[2] + "</b>";
          break;
          case "font-style: italic;":
          return "<i>" + arguments[2] + "</i>";
          break;
        }
      });
    }
    string = string.replace(/<([o|u])l id="null">/g,"<$1l>");
  } else if (window.gecko) {

  }
  string = string.replace(/<br[ \/]*>$/i,"");
  return string;
}