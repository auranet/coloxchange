Object.extend(App,{
  "select.filter-select,select.filter-select::change":function(element,event) {
    Editors[element.getParent().getElement("textarea").id].mode = element.value;
  },
  "a.add-section::click":function(element,event) {
    event.stop();
    var select = $(element.getAttribute("rel"));
    var option = $A(select.options).filter(function(option){return option.selected;})[0];
    try {option.remove();}catch(e){select.removeChild(option);}
    if (select.options.length == 0) select.getParent().setStyle("display","none");
    var baseTab = $("body-tab");
    var tabset = baseTab.getParent().getParent();
    var baseDiv = $("instance-body");
    var newTab = baseTab.clone().setProperty("rel","instance-"+option.value).removeClass("active").setHTML(option.innerHTML+"&nbsp;&nbsp;").injectAfter(baseTab).addClass("close");
    var newDiv = baseDiv.clone().setProperty("id","instance-"+option.value).setStyle("display","none").injectAfter(baseDiv);
    newDiv.getElement("select").setProperty("name","instance[page_section_hashes]["+option.value+"][body_filter]");
    var textarea = new Element("textarea",{"class":"editor",id:"page_" + option.value + "_editor",name:"instance[page_section_hashes]["+option.value+"][body]",rel:"wysiwyg"});
    newDiv.getElement("div.editor").replaceWith(textarea);
    var newTabRemove = new Element("span").setStyle("paddingLeft",10).inject(newTab).setHTML(" ");
    App["div.tabset"].attempt(baseTab.getParent().getParent());
    newTab.fireEvent("click");
    MooSelectors.assign(App,newDiv);
  },
  "div.tabset":function(element) {
    var tabs = element.getElements("a.tab");
    tabs.forEach(function(tab){
      tab.removeEvents("click");
      tab.addEvent("click",function(){
        var active = element.getElement("a.active");
        if (active) {
          active.removeClass("active");
          $(active.getAttribute("rel")).setStyle("display","none");
        }
        tab.addClass("active");
        $(tab.getAttribute("rel")).setStyle("display","block");
      });
      var removeLink = tab.getElement("span");
      if (removeLink) removeLink.addEvent("click",function(){
        tabs[0].fireEvent("click");
        var tab = removeLink.getParent();
        $(tab.getAttribute("rel")).remove();
        var select = $(tab.getParent().getParent().getElement("a.add-section").getAttribute("rel"));
        var option = new Element("option",{value:tab.getAttribute("rel").replace("instance-","")}).setHTML(tab.innerHTML.split("&nbsp;&nbsp;")[0]).injectInside(select);
        option.selected = true;
        select.getParent().setStyle("display","");
        tab.remove();
      });
    });
  },
  ".page-filter-link":function(element) {
    element.removeEvents("click");
  },
  ".page-filter-link::click":function(element,event) {
    event.stop();
    Controller.StartSpinner();
    var filter = element.getParent().getElement("select").value;
    new Ajax(element.href.replace(/\/help\/[\w-]+/ig,"/help/" + filter),{method:"get",update:$("right")}).request();
  }
});