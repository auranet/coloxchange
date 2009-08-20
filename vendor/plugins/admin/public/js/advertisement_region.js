var singleClick = false;
Object.extend(App,{
  "#map":function(element) {
    var latLng = element.innerHTML.split("::");
    var sw = latLng[0].split("x");
    var ne = latLng[1].split("x");
    element.setHTML("").setStyle("display","");
    Controller.Map.map = new GMap2(element);
    Controller.Map.map.enableScrollWheelZoom();
    Controller.Map.map.addControl(new GSmallMapControl());
    if (sw[0] != "" && sw[1] != "" && ne[0] != "" && ne[1] != "") {
      var bounds = new GLatLngBounds(new GLatLng(sw[0],sw[1]),new GLatLng(ne[0],ne[1]));
      Controller.Map.map.setCenter(bounds.getCenter(),Controller.Map.map.getBoundsZoomLevel(bounds));
      Controller.Map.drawBoxFromBounds(bounds);
    } else {
      Controller.Map.map.setCenter(new GLatLng(39.833333,-98.583333),3);
      GEvent.addListener(Controller.Map.map,"click",function(overlay,point) {
        if (point && !Controller.Map.box) {
          singleClick = !singleClick;
          setTimeout("if (singleClick) Controller.Map.drawBoxFromScratch(new GLatLng(" + point.y + "," + point.x + "));",300)
        }
      });
    }
  }
});

Object.extend(Controller,{
  Map: {
    box:false,
    map:false,
    drag:function() {
      var point = this.mapHandle.getPoint();
      var difLat = point.lat() - this.mapHandleOrigin.lat();
      var difLng = point.lng() - this.mapHandleOrigin.lng();
      var sw = this.sw.getPoint(),ne = this.ne.getPoint();
      this.mapHandleOrigin = point;
      var newSW = new GLatLng(sw.lat() + difLat,sw.lng() + difLng);
      this.sw.setPoint(newSW);
      this.matchLat(newSW,"se");
      this.matchLng(newSW,"nw");
      var newNE = new GLatLng(ne.lat() + difLat,ne.lng() + difLng)
      this.ne.setPoint(newNE);
      this.matchLat(newNE,"nw");
      this.matchLng(newNE,"se");
      this.draw();
    },
    draw:function(marker) {
      this.map.removeOverlay(this.box);
      this.box = new GPolygon([this.sw.getPoint(),this.se.getPoint(),this.ne.getPoint(),this.nw.getPoint(),this.sw.getPoint()],"#0000ff",2,0.5,"#0000ff",0.2);
      this.map.addOverlay(this.box);
      this.mapHandle.setPoint(new GLatLngBounds(this.getSW(),this.getNE()).getCenter());
      this.mapHandleOrigin = this.mapHandle.getPoint();
      this.setBounds();
    },
    drawBox:function(point) {
      if (!point) var point = this.map.getCenter();
      this.origin = point;
      this.swLat = $("instance_sw_lat");
      this.swLng = $("instance_sw_lng");
      this.neLat = $("instance_ne_lat");
      this.neLng = $("instance_ne_lng");
      var handleIcon = new GIcon(false,"/global/admin/images/icons/drag.png");
      handleIcon.iconSize = new GSize(16,16);
      handleIcon.dragCrossSize = new GSize(0,0);
      handleIcon.iconAnchor = new GPoint(8,8);
      this.mapHandle = new GMarker(point,{icon:handleIcon,draggable:true,bouncy:false,dragCrossMove:true});
      this.map.addOverlay(this.mapHandle);
      this.mapHandleOrigin = point;
      GEvent.addListener(this.mapHandle,"drag",this.drag.bind(this));
      this.cornerIcon = new GIcon(false,"/global/admin/images/icons/drag-corner.png");
      this.cornerIcon.iconSize = new GSize(11,11);
      this.cornerIcon.dragCrossSize = new GSize(0,0);
      this.cornerIcon.iconAnchor = new GPoint(5,5);
    },
    drawBoxFromBounds:function(bounds) {
      this.drawBox();
      var sw = bounds.getSouthWest(),ne = bounds.getNorthEast(),options = {icon:this.cornerIcon,draggable:true,bouncy:false,dragCrossMove:true};
      this.sw = new GMarker(sw,options);
      this.se = new GMarker(new GLatLng(sw.lat(),ne.lng()),options);
      this.ne = new GMarker(ne,options);
      this.nw = new GMarker(new GLatLng(ne.lat(),sw.lng()),options);
      this.drawBoxVertices();
    },
    drawBoxFromScratch:function(point) {
      this.drawBox(point);
      this.drawBoxVertices(point);
    },
    drawBoxVertices:function(point) {
      ["sw","se","ne","nw"].forEach(function(marker) {
        if (!this[marker]) this[marker] = new GMarker(point,{icon:this.cornerIcon,draggable:true,bouncy:false,dragCrossMove:true});
        this.map.addOverlay(this[marker]);
        GEvent.addListener(this[marker],"drag",function() {
          this.matchLat(this[marker].getPoint(),marker == "sw" ? "se" : marker == "se" ? "sw" : marker == "ne" ? "nw" : marker == "nw" ? "ne" : false);
          this.matchLng(this[marker].getPoint(),marker == "sw" ? "nw" : marker == "se" ? "ne" : marker == "ne" ? "se" : marker == "nw" ? "sw" : false);
          this.draw();
        }.bind(this));
      }.bind(this));
      this.draw();
    },
    getNE:function() {
      var sw = this.sw.getPoint();
      var ne = this.ne.getPoint();
      return new GLatLng(Math.max(sw.lat(),ne.lat()),Math.max(sw.lng(),ne.lng()));
    },
    getSW:function() {
      var sw = this.sw.getPoint();
      var ne = this.ne.getPoint();
      return new GLatLng(Math.min(sw.lat(),ne.lat()),Math.min(sw.lng(),ne.lng()));
    },
    matchLat:function(point,match) {
      match = this[match];
      match.setPoint(new GLatLng(point.lat(),match.getPoint().lng()));
    },
    matchLng:function(point,match) {
      match = this[match];
      match.setPoint(new GLatLng(match.getPoint().lat(),point.lng()));
    },
    setBounds:function() {
      var sw = this.getSW();
      var ne = this.getNE();
      this.swLat.value = sw.lat();
      this.swLng.value = sw.lng();
      this.neLat.value = ne.lat();
      this.neLng.value = ne.lng();
    }
  }
});
