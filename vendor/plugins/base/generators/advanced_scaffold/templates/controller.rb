class <%= class_name.pluralize %>Controller < ApplicationController
  before_filter :set_model
  before_filter :find_<%= file_name %>,:only => [:destroy,:edit,:show,:update]
<% if actions.include?("autocomplete") -%>

  def autocomplete
    if params[:value]
      queryset = <%= class_name %>.filter
      for term in params[:value].split(" ")
        queryset.filter(:name__like => term)
      end
      @<%= file_name.pluralize %> = queryset.find(:all,:order => ["<%= file_name.tableize %>.name"])
    end
    render :layout => false
  end
<% end -%>

  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = "#{@<%= file_name %>.name} has been created"
        format.html { request.xhr? ? render(:partial => "layouts/messages") : redirect_to(@<%= file_name %>) }
        format.xml { render :xml => @<%= file_name %>,:status => :created,:location => @<%= file_name %> }
      else
        flash[:error] = "This <%= class_name.tableize.humanize.singularize.downcase %> could not be created"
        flash[:error_list] = @<%= file_name %>.error_list
        format.html { render :action => "form",:layout => !request.xhr? }
        format.xml { render :xml => @<%= file_name %>.errors,:status => :unprocessable_entity }
      end
    end
  end

  def destroy
    if params[:confirm] == "yes"
      @<%= file_name %>.destroy
      flash[:delete] = "#{@<%= file_name %>.name} has been deleted"
      respond_to do |format|
        format.html { request.xhr? ? render(:partial => "layouts/messages",:locals => {:return_url => url_for(return_url)}) : redirect_to(<%= file_name.pluralize %>_path) }
        format.xml { head :ok }
      end
      return
    end
    @title = "Delete #{@<%= file_name %>.name}?"
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.xml { render :xml => @<%= file_name %> }
    end
  end

  def edit
    @title = "Editing #{@<%= file_name %>.name}"
    respond_to do |format|
      format.html { render :action => "form",:layout => !request.xhr? }
      format.xml { render :xml => @<%= file_name %> }
    end    
  end

  def index
    @title = "<%= class_name.tableize.humanize.titleize %>"<% if actions.include?("filter") %>
    session[:filter][:<%= file_name %>] = params[:filter] ||= session[:filter][:<%= file_name %>] : {}
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
    @<%= file_name.pluralize %> = <%= class_name %>.paginate(<%= ":conditions => queryset.conditions,:include => queryset.includes" if actions.include?("filter") %>:order => "<%= file_name.pluralize %>.name",:page => params[:page])
    respond_to do |format|
      format.html<% if actions.include?("filter") %> { render :layout => !request.xhr? }<% end %>
      format.xml { render :xml => @<%= file_name.pluralize %> }
    end
  end

  def new
    @title = "Add a <%= class_name.tableize.humanize.singularize.downcase %>"
    @<%= file_name %> = <%= class_name %>.new
    respond_to do |format|
      format.html { render :action => "form",:layout => !request.xhr? }
      format.xml { render :xml => @<%= file_name %> }
    end
  end

  def show
    @title = @<%= file_name %>.name
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.xml { render :xml => @<%= file_name %> }
    end
  end

  def update
    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = "#{@<%= file_name %>.name} has been saved"
        format.html { request.xhr? ? render(:partial => "layouts/messages") : redirect_to(return_url) }
        format.xml { head :ok }
      else
        flash[:error] = "This <%= class_name.tableize.humanize.singularize.downcase %> could not be saved"
        flash[:error_list] = @<%= file_name %>.error_list
        format.html { render :action => "form",:layout => !request.xhr? }
        format.xml { render :xml => @<%= file_name %>.errors,:status => :unprocessable_entity }
      end
    end
  end
<% for action in actions.without("autocomplete","filter") -%>
  def <%= action %>
    
  end

<% end -%>

  private
  def find_<%= file_name %>
    return deny if params[:id].nil? || (params[:id] && !(@<%= file_name %> = <%= class_name %>.find(:first,:conditions => ["<%= file_name.pluralize %>.id = ?",params[:id]])))
    @instance = true if @<%= file_name %>
  end

  def set_model
    @model = "<%= file_name.titleize %>"
  end

  def set_return
    session[:return] = @<%= file_name %> ? {:controller => "<%= file_name.pluralize %>",:action => "show",:id => @<%= file_name %>.id} : {:controller => "<%= file_name.pluralize %>",:action => "index"}
  end
end