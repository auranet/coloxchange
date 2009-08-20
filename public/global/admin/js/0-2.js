Object.extend(App, {
  "button::click": function(element,event) {
    $(element.form).getElements("button").forEach(function(button) {
      if (element != button)
        button.name = "";
    });
    if (element.getAttribute("name")) {
      var input = new Element("input",{name:element.name,type:"hidden",value:element.value});
      element.name = "";
      element.parentNode.appendChild(input);
    }
  }
});