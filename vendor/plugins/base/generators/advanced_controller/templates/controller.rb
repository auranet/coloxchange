class <%= class_name %>Controller < AppController
  before_filter :set_model
  before_filter :find_<%= file_name %>,:only => [:delete,:edit,:view]
<% if actions.include?("filter") -%>

  def autocomplete
    if params[:value]
      queryset = <%= class_name %>.filter
      for term in params[:value].split(" ")
        queryset & <%= class_name %>.filter(:name__like => term)
      end
      @<%= file_name.pluralize %> = queryset.find(:all,:order => ["<%= file_name.tableize %>.name"])
    else
      @<%= file_name.pluralize %> = []
    end
    render :layout => false
  end
<% end -%>

  def delete
    if params[:confirm] == "yes"
      @<%= file_name %>.destroy
      flash[:delete] = "#{@<%= file_name %>.name} has been deleted"
      redirect_to :action => "index" and return
    end
    @title = "Delete #{@<%= file_name %>.name}?"
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.xml { render :xml => @<%= file_name %> }
    end
  end

  def edit
    @<%= file_name %> ||= <%= class_name %>.new
    new_record = @<%= file_name %>.new_record?
    if request.post?
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = "#{@<%= file_name %>.name} has been #{new_record ? "created" : "saved"}"
        redirect_to new_record ? {:action => "show",:id => @<%= file_name %>.id} : return_url || {:action => "index"} and return
      else
        flash[:error] = "This <%= file_name.humanize.downcase %> could not be #{new_record ? "created" : "saved"}"
        flash[:error_list] = @<%= file_name %>.error_list
      end
    end
    @title = new_record ? "Add a <%= class_name.tableize.humanize.singularize.downcase %>" : "Editing #{@<%= file_name %>.name}"
  end

  def index
    @title = "<%= class_name.tableize.humanize.titleize %>"<% if actions.include?("filter") %>
    session[:filter][:<%= file_name %>] = (params[:filter] ||= session[:filter][:<%= file_name %>] || {})
    queryset = <%= class_name %>.filter
    for key,value in params[:filter]
      if key.include?("name")
        for name in value.split(" ")
          queryset.filter("#{key}__contains" => name) unless name == ""
        end
      elsif value != ""
        queryset.filter("#{key}#{"__in" if value.is_a?(Array)}" => value)
      end
    end if params[:filter]<% end %>
    @<%= file_name.pluralize %> = <%= class_name %>.paginate(<%= ":conditions => queryset.conditions,:include => queryset.includes" if actions.include?("filter") %>,:order => "<%= file_name.pluralize %>.name",:page => params[:page])<% if actions.include?("filter") %>
    render :layout => !request.xhr?<% end %>
  end

  def view
    @title = @<%= file_name %>.name
  end

<% for action in actions.without("autocomplete","filter") -%>
  def <%= action %>
    
  end

<% end -%>

  private
  def find_<%= file_name %>
    return deny if params[:id] && !(@<%= file_name %> = <%= class_name %>.find(:first,:conditions => ["<%= file_name.pluralize %>.id = ?",params[:id]]))
    @instance = true if @<%= file_name %>
  end

  def set_model
    @model = "<%= file_name.titleize %>"
  end

  def set_return
    session[:return] = @<%= file_name %> && !@<%= file_name %>.new_record? ? {:controller => "<%= file_name %>",:action => "show",:id => @<%= file_name %>.id} : {:controller => "<%= file_name %>",:action => "index"}
  end
end