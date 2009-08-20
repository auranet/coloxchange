class Filters < Widget
  def title
    "Search"
  end

  def render
    filters = ""
    model = self.options[:model].constantize
    raise "break" if self.options[:filters].empty?
    for filter in self.options[:filters]
      filters << "#{link_to(filter[:label],{:action => "browse",:model => filter[:type] == :reflection ? model.reflections[filter[:name]].class_name.tableize : filter[:name]},:class => "collapse#{' expanded' unless filter[:collapsed]}",:rel => "filter-#{filter[:name]}")}
<div class=\"filter\" id=\"filter-#{filter[:name]}\"#{' style="display:none;"' if filter[:collapsed]}>"
      case filter[:type]
      when :string,:text
        filters << self.controller.response.template.text_field("filter",filter[:name],:class => "text")
      when :boolean
        filters << self.controller.response.template.yesno("filter",filter[:name],:class => "radio")
      when :integer,:float,:date,:datetime
        # <%= hidden_field_tag("filter[#{filter[:name]}][min]","0",:class => "hidden",:id => "filter-#{filter[:name]}-min") %>
        #       <%= hidden_field_tag("filter[#{filter[:name]}][max]","1000",:class => "hidden",:id => "filter-#{filter[:name]}-max") %>
        #       <div class="slider" id="filter-slider-<%= filter[:name] %>"><div class="slider-handle min"></div><div class="slider-handle max"></div></div>
      # when :belongs_to
      #   filters << self.controller.response.template.select("filter",filter[:name],filter[:choices])
      #   # filters << "<div class=\"filter-choices\" id=\"filter-options-#{filter[:name]}\"></div>"
      when :belongs_to,:has_many,:has_and_belongs_to_many,:has_one
        if filter[:choices].empty?
          filters << "<div class=\"quiet\">No #{filter[:label].downcase}!</div>"
        else
          filters << filter[:choices].collect{|choice| "<label for=\"filter-#{filter[:name]}-#{choice[1]}\">#{self.controller.response.template.check_box_tag("filter[#{filter[:name]}][]",choice[1],self.controller.request.parameters[:filter] && self.controller.request.parameters[:filter][filter[:name]] ? self.controller.request.parameters[:filter][filter[:name]].include?(option[1].to_s) : true,:class => "checkbox",:id => "filter-#{filter[:name]}-#{choice[1]}")} #{choice[0]}</label>"}.join("<br />\n")
        end
      else
        filters << "IDK: #{filter[:type]}"
      end
      filters << "</div>"
    end
    filters
  end
end