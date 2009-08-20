Object.extend(App,{
  "a.bulk-add::click":function(element,event) {
    event.stop();
    var bulkRow = $("bulk-row");
    var table = bulkRow.findParent("tbody");
    bulkRow = bulkRow.clone().setStyle("display","").injectInside(table);
    Controller.Reorder(table);
    MooSelectors.assign.delay(200,MooSelectors,[App,bulkRow]);
  },
  "a.bulk-remove::click":function(element,event) {
    event.stop();
    var table = element.findParent("tbody");
    element.getParent().getParent().remove();
    Controller.Reorder(table);
  }
});
