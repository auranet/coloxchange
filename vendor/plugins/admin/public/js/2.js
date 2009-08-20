var Filtering;
Object.extend(App,{
  "body":function(element) {
    Filtering = new Filter($("filter-form"),{update:$("browse-table")});
  },
  ".filter input.checkbox,.filter input.radio,.filter div.filter-choices input,.filter input.text,.filter div.slider":function(element) {
    Filtering.observe(element);
  }
});

var Filter = new Class({
  delay:false,
  options:{delay:500},
  initialize:function(form,options) {
    this.form = form;
    this.setOptions(options);
  },
  delayRunFilter:function() {
    if (this.delay)
    $clear(this.delay);
    this.delay = this.runFilter.delay(this.options.delay,this);
  },
  observe:function(input) {
    if (input.tagName == "INPUT") {
      input.addEvent(input.hasClass("text") ? "keypress" : "change",this.delayRunFilter.bind(this));
    } else {
      var id = "filter-" + input.id.replace("filter-slider-","");
      var min = $(id + "-min");
      var max = $(id + "-max");
      new Slider(input,input.getElement(".slider-handle"),{start:parseFloat(min.value),end:parseFloat(max.value),knobheight:21,onChange:function(pos){
        alert(pos);
        }},input.getElements(".slider-handle")[1]);
      }
    },
    runFilter:function() {
      Controller.StartSpinner("Filtering...");
      new Ajax(this.form.action,{data:this.form.toQueryString(),method:"get",update:this.options.update}).request();
    }
  });
  Filter.implement(new Options);

  var Slider = new Class({
    options: {
      onChange: Class.empty,
      onComplete: Class.empty,
      onTick: function(pos){
        this.moveKnob.setStyle(this.p, pos);
      },
      start: 0,
      end: 100,
      offset: 0,
      knobheight: 20,
      mode: 'horizontal'
    },
    initialize: function(el, knob, options, maxknob) {
      this.element = $(el);
      this.knob = $(knob);
      this.setOptions(options);
      this.previousChange = -1;
      this.previousEnd = -1;
      this.step = -1;
      this.options.steps = this.options.end - this.options.start;

      if(maxknob!=null)
      this.maxknob = $(maxknob);
      else
      this.element.addEvent('mousedown', this.clickedElement.bindWithEvent(this));
      var mod, offset;
      switch(this.options.mode){
        case 'horizontal':
        this.z = 'x';
        this.p = 'left';
        mod = {'x': 'left', 'y': false};
        offset = 'offsetWidth';
        break;
        case 'vertical':
        this.z = 'y';
        this.p = 'top';
        mod = {'x': false, 'y': 'top'};
        offset = 'offsetHeight';
      }
      this.max = this.element[offset] - this.knob[offset] + (this.options.offset * 2);
      this.half = this.knob[offset]/2;
      this.getPos = this.element['get' + this.p.capitalize()].bind(this.element);
      this.knob.setStyle('position', 'relative').setStyle(this.p, - this.options.offset);
      if(maxknob != null) {
        this.maxPreviousChange = -1;
        this.maxPreviousEnd = -1;
        this.maxstep = this.options.end;
        this.maxknob.setStyle('position', 'relative').setStyle(this.p, + this.max - this.options.offset).setStyle('bottom', this.options.knobheight);
      }
      var lim = {};
      lim[this.z] = [- this.options.offset, this.max - this.options.offset];
      this.drag = new Drag.Base(this.knob, {
        limit: lim,
        modifiers: mod,
        snap: 0,
        onStart: function(){
          this.draggedKnob();
        }.bind(this),
        onDrag: function(){
          this.draggedKnob();
        }.bind(this),
        onComplete: function(){
          this.draggedKnob();
          this.end();
        }.bind(this)
      });
      if(maxknob != null) {  
        this.maxdrag = new Drag.Base(this.maxknob, {
          limit: lim,
          modifiers: mod,
          snap: 0, 
          onStart: function(){
            this.draggedKnob(1);
          }.bind(this),
          onDrag: function(){
            this.draggedKnob(1);
          }.bind(this),
          onComplete: function(){
            this.draggedKnob(1);
            this.end();
          }.bind(this)
        });
      }
      if (this.options.initialize) this.options.initialize.call(this);
    },
    setMin: function(stepMin){
      this.step = stepMin.limit(this.options.start, this.options.end);
      this.checkStep();
      this.end();
      this.moveKnob = this.knob;
      this.fireEvent('onTick', this.toPosition(this.step));
      return this;
    },
    setMax: function(stepMax){
      this.maxstep = stepMax.limit(this.options.start, this.options.end);
      this.checkStep(1);
      this.end();
      this.moveKnob = this.maxknob;
      this.fireEvent('onTick', this.toPosition(this.maxstep));
      return this;
    },
    clickedElement: function(event){
      var position = event.page[this.z] - this.getPos() - this.half;
      position = position.limit(-this.options.offset, this.max -this.options.offset);
      this.step = this.toStep(position);
      this.checkStep();
      this.end();
      this.fireEvent('onTick', position);
    },
    draggedKnob: function(mx){
      if(mx==null) {
        this.step = this.toStep(this.drag.value.now[this.z]);
        this.checkStep();
      }
      else {  
        this.maxstep = this.toStep(this.maxdrag.value.now[this.z]);
        this.checkStep(1);
      }
    },
    checkStep: function(mx){
      if(mx==null) {
        if (this.previousChange != this.step){
          this.previousChange = this.step;
        }
      }
      else {  
        if (this.maxPreviousChange != this.maxstep){
          this.maxPreviousChange = this.maxstep;
        }
      }
      if(this.maxknob!=null) {
        if(this.step < this.maxstep)
        this.fireEvent('onChange', { minpos: this.step, maxpos: this.maxstep });
        else    
        this.fireEvent('onChange', { minpos: this.maxstep, maxpos: this.step });
      }
      else {  
        this.fireEvent('onChange', this.step);
      }
    },
    end: function(){
      if (this.previousEnd !== this.step || (this.maxknob != null && this.maxPreviousEnd != this.maxstep)) {
        this.previousEnd = this.step;
        if(this.maxknob != null) {
          this.maxPreviousEnd = this.maxstep;
          if(this.step < this.maxstep)
          this.fireEvent('onComplete', { minpos: this.step + '', maxpos: this.maxstep + '' });
          else    
          this.fireEvent('onComplete', { minpos: this.maxstep + '', maxpos: this.step + '' });
        }
        else {  
          this.fireEvent('onComplete', this.step + '');
        }
      }
    },
    toStep: function(position){
      return Math.round((position + this.options.offset) / this.max * this.options.steps) + this.options.start;
    },
    toPosition: function(step){
      return (this.max * step / this.options.steps) - (this.max * this.options.start / this.options.steps) - this.options.offset;
    }
  });
  Slider.implement(new Events);
  Slider.implement(new Options);