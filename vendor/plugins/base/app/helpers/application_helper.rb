module ApplicationHelper
  def button(label,options = {:class => "button"})
    options[:class] = "button #{options[:class]}" if options[:class] && !options[:class].include?("button")
    submit_tag(label,options)
  end

  def end_form
    "</div></form>"
  end

  def paginate_links(pages)
    str = ""
    str += "#{link_to("&laquo; Back",:page => pages.current.previous)}" if pages.current.previous
    str += "#{pagination_links(pages,:window_size => 10)}"
    str += " #{link_to("Next &raquo;",url_for(:replace => {:page => pages.current.previous}))}" if pages.current.next
    return str
  end

  def return_url
    session[:return] || {}
  end

  def start_form(url={},options={})
    "#{form_tag(url,options)}<div>"
  end

  def state_select(instance,method,options = {},html_options = {})
    select(instance,method,['AL','AK','AR','AZ','CA','CO','CT','DC','DE','FL','GA', 'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD', 'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ', 'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC', 'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY'].sort,options,html_options)
  end

  def state_select_tag(name,value,options ={})
    select_tag(name,options_for_select(['AL','AK','AR','AZ','CA','CO','CT','DC','DE','FL','GA', 'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD', 'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ', 'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC', 'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY'].sort.unshift(options.delete(:include_blank) ? "" : nil).compact,value),options)
  end

  def yesno(record,method,options = {})
    "<label for=\"#{record}_#{method}_true\">#{radio_button(record,method,true,options)} Yes</label> <label for=\"#{record}_#{method}_false\">#{radio_button(record,method,false,options)} No</label>"
  end
end