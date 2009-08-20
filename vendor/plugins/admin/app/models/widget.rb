class Widget
  attr_accessor :collapsed,:controller,:options,:user
  def initialize(controller,user,options = {})
    return nil if user.nil?
    self.collapsed = (user.admin_widgets.select{|admin_widget| admin_widget.widget == self.title.tableize.singularize.gsub(" ","_")}[0] || user.admin_widgets.create(:widget => self.title.tableize.singularize.gsub(" ","_"))).collapsed
    self.controller = controller
    self.options = options
    self.user = user
  end

  def link_to(label,url = {},options = {})
    self.controller.response.template.link_to(label,url,options)
  end

  def link_to_unless(condition,label,url = {},options = {})
    self.controller.response.template.link_to_unless(condition,label,url,options)
  end

  def render_widget
    return "<div class=\"widget\">
  <h2>#{link_to self.title,{:action => "widget",:id => self.class.to_s.tableize.singularize},:class => "right-expand#{' expanded' unless self.collapsed}",:rel => "widget_#{self.title.tableize.gsub(" ","_")}"}</h2>
  <div class=\"widget-container\" id=\"widget_#{self.title.tableize.gsub(" ","_")}\"#{' style="display:none;"' if self.collapsed}>
#{self.render}
  </div>
  <div class=\"widget-bottom\"><div class=\"widget-bottom-right\"></div></div>
</div>"
  rescue
    return ""
  end
end