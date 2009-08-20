module AdminHelper
  def admin_button(label,options={})
    options = {:type => "submit"}.merge(options)
    return "<a class=\"button\"><button#{options.to_html}>#{label}</button></a>"
  end

  def admin_button_link(label,url = {},options = {})
    if !options[:class].nil? and !options[:class].include?("button")
      options[:class] << " button-link"
    elsif options[:class].nil?
      options[:class] = "button-link"
    end
    link_to("<span>#{label}</span>",url,options)
  end

  def admin_input(record,method,options = {})
    instance = instance_variable_get("@#{record}")
    method = method.to_s
    method = "#{method}_id" if instance.respond_to?("#{method}_id")
    if options[:choices]
      return select(record,method,options.delete(:choices),{},options)
    end
    case instance.column_for_attribute(method).type.to_s.to_sym
    when :string,:NilClass
      case method
      when "name"
        text_field(record,method,{:class => "oversize text"}.update(options.without(:label)))
      when "slug"
        "#{text_field(record,method,{:class => "#{"slug " if instance.new_record?}text",:rel => "#{record}_name",:disabled => instance.new_record? ? nil : "disabled"}.update(options.without(:label)))} #{admin_unlock("#{record}_#{method}")}"
      else
        unless options[:class]
          options[:class] = "text"
        end
        if method =~ /(filename|path)/
          file_field(record,method,options.without(:label))
        elsif method.include?("password")
          password_field(record,method,options.without(:label))
        else
          text_field(record,method,options.without(:label))
        end
      end
    when :text
      options[:rel] = instance.send("#{method}_filter") if options[:class] && options[:class].include?("editor") && instance.respond_to?("#{method}_filter")
      text_area(record,method,options)
    when :integer
      if method =~ /_id$/ && reflection = instance.class.reflections[method.gsub("_id","").to_sym]
        add_another = admin_button_link("Add another",{:action => "edit",:model => reflection.class_name.tableize.singularize,:id => nil,:external => "yes"},:class => "add external",:rel => "#{record}_#{method}")
        model = reflection.class_name.constantize
        admin_options = model.admin_options
        method = method.gsub("_id","")
        if model.count > 50
          "#{text_field_tag("#{method}",instance.send(method) ? instance.send(method).name : "",:alt => url_for(:action => "search",:model => reflection.class_name.tableize,:id => nil),:class => "complete text",:rel => "#{record}_#{method}_id")}#{hidden_field(record,"#{method}_id")} #{add_another}<div class=\"quiet\">Type a name in the box</div>"
        else
          "#{select_tag("#{record}[#{method}_id]","<option label=\"(none)\" value=\"\">(none)</option>#{options_from_collection_for_select(model.find(:all,:include => admin_options[:include],:order => model.admin_order),"id",model.new.respond_to?(:admin_name) ? "admin_name" : "name",params[method] ? params[method] =~ /\d+/ ? params[method].to_i : params[method] : instance.send("#{method}_id"))}",options.update({:id => "#{record}_#{method}_id"}))} #{add_another}"
        end
      elsif method =~ /_in_cents$/
        "#{text_field(record,method.gsub(/_in_cents$/,""),{:class => "integer small text"})} #{currency}"
      else
        text_field(record,method,{:class => "integer small text"})
      end
    when :decimal,:float
      text_field(record,method,{:class => "decimal small text"})
    when :date
      "#{date_select(record,method,{:order => [:month,:day,:year]}.update(options))} #{link_to("&nbsp;",{},:class => "calendar icon",:rel => "#{record}_#{method}")}"
    when :datetime,:timestamp
      "#{date_select(record,method,{:order => [:month,:day,:year]}.update(options))} #{time_select(record,method,options)} "
    when :time
      time_select(record,method)
    when :boolean
      yesno(record,method)
    else
      raise "#{instance.class} attribute \"#{method}\" is of unknown type: #{instance.column_for_attribute(method).type.inspect}"
    end
  end

  def admin_bulk_tag(options)
    name = "instances[][#{options[:name]}]"
    case options[:type]
    when :string
      if options[:name].to_sym == :path
        file_field_tag(name)
      else
        text_field_tag(name,"",{:class => "medium text"})
      end
    when :integer
      text_field_tag(name,"",{:class => "integer small text"})
    when :decimal,:float
      text_field_tag(name,"",{:class => "decimal small text"})
    when :date
      date_select_tag(name,options)
    when :time
      time_select_tag(name,options)
    when :refection

    else
      text_field_tag(name,"",{:class => "medium text"}.update(options.without(:label)))
    end
  end

  def admin_unlock(id)
    link_to("&nbsp;",{},:class => "unlock",:rel => id)
  end
end