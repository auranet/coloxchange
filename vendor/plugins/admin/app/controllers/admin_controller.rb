class AdminController < ApplicationController
  # #     CSS           JS
  # 0     global        libraries
  # 1     layout        app
  # 2     layout-small  filters
  # 3     forms         bulk
  # 4     tables        editor
  # 5     editor        autocomplete
  # 6     nil           tinyMCE
  # 0-1   fixie         nil
  # 0-2   fixie6        fixie6
  @@templates = []
  skip_before_filter :load_context_data
  skip_before_filter :context_data
  before_filter :start_context_data
  before_filter :require_admin,:except => [:setup]
  before_filter :more_context_data
  before_filter :set_model,:only => [:browse,:bulk_add,:delete,:deleteall,:edit,:editall,:export,:filter,:help,:import,:list,:reports,:reorder,:search,Admin.extensions.values].flatten
  before_filter :set_instance,:only => [:browse,:bulk_add,:delete,:edit,:filter,:list,:reports,Admin.extensions.values].flatten
  before_filter :set_filters,:only => [:browse,:filter]
  cache_sweeper :admin_sweeper,:only => [:edit,:delete,:deleteall,:reorder,Admin.extensions.values].flatten if Rails.plugins[:cms]
  layout :admin_layout

  def admin_role_permissions
    if @user.admin_omnipotent? && params[:id] && admin_role = AdminRole.find(:first,:conditions => ["admin_roles.id = ?",params[:id]])
      if request.post?
        admin_role.admin_permissions.clear
        for permission in params[:permissions]
          if permission[:model]
            permission[:model] = permission[:model].singularize
            admin_role.admin_permissions.find_or_initialize_by_model(permission[:model]).update_attributes(permission)
          end
        end
        flash[:update] = "#{admin_role.name.possessive} new permissions have been saved"
      end
      redirect_to :action => "edit",:model => "admin_role",:id => params[:id]
    else
      admin_deny
    end
  end

  def browse
    if request.xhr?
      if params[:collapsed]
        if session["expanded_#{@model_class}"]
          session["expanded_#{@model_class}"] -= [Integer(params[:parent])]
        end
      elsif params[:parent]
        @children = @model.find(:all,:conditions => ["#{@model.table_name}.parent_id = ?",params[:parent]],:order => "#{@model_class}.position ASC")
        if session["expanded_#{@model_class}"]
          unless session["expanded_#{@model_class}"].include?(Integer(params[:parent]))
            session["expanded_#{@model_class}"] << Integer(params[:parent])
          end
        else
          session["expanded_#{@model_class}"] = [Integer(params[:parent])]
        end
        sortable = @instance.respond_to?(:move_to_top)
        render :partial => "browse_table_tree_rows",:locals => {:advanced => true,:children => @children,:class_name => @model_class,:columns => @options[:browse_columns],:deletable => @model.admin_deletable,:external => @external,:sortable => sortable,:tree => true,:width => width = @options[:browse_columns].size > 1 ? "#{100/(@options[:browse_columns].size + (sortable ? 2 : !@options[:deletable] ? 0 : 1))}%" : "auto"} and return
      end
      render :text => ""
    else
      @css.push("3","4")
      @js.push("2")
      @title = @model_name
      @right = "filters"
      # Decide on the proper sort order
      @order_sort = params[:sort] && params[:sort] == "down" ? "DESC" : "ASC"
      # Ensure pre-existing ASC/DESCs get reversed on reverse sort
      if @order_sort == "DESC" && @options[:order] =~ /(ASC|DESC)/
        new_order = ""
        scanner = StringScanner.new(@options[:order])
        while scanner.scan_until(/(ASC|DESC)/)
          new_order << "#{scanner.pre_match}#{scanner.matched == "ASC" ? "DESC" : "ASC"}"
          scanner = StringScanner.new(scanner.post_match)
        end
        @options[:order] = new_order
      else
        @options[:order] = "#{@options[:order].to_s} #{@order_sort}" unless @options[:order] =~ /(ASC|DESC)/
      end
      # Build sort columns for everything other than pre-existing
      columns = [@options[:order],@options[:browse_columns][1,@options[:browse_columns].size - 1].collect{|column| column.is_a?(Hash) ? column.keys.first.to_s : column}].flatten.compact
      columns[1,columns.size - 1].each_with_index do |column,index|
        if column.to_s.include?(".") && @model.reflections[column.split(".").first.to_sym] && !@options[:include].any?{|includes| includes.is_a?(Array) ? includes.include?(column.split(".")[0]) : includes.is_a?(Hash) ? includes.keys.any?{|key| key.to_s == column.split(".")[0]} : includes == column.split(".")[0]}
          reflection_model = @model.reflections[column.split(".").first.to_sym].active_record
          @options[:include] << column.split(".")[0].to_sym
          if reflection_model.respond_to?("#{column.split(".")[1]}_attributes")
            columns[index+1] = reflection_model.send("#{column.split(".")[1]}_attributes").collect{|column| "#{reflection_model.table_name}.#{column} #{@order_sort}"}.join(",")
          else
            columns[index+1] = "#{reflection_model.table_name}.#{column.split(".")[1]} #{@order_sort}"
          end
        elsif @model.respond_to?("#{column}_attributes")
          columns[index+1] = @model.send("#{column}_attributes").collect{|column| "#{@model.table_name}.#{column} #{@order_sort}"}.join(",")
        else
          columns[index+1] = "#{column} #{@order_sort}"
        end
      end
      # Grab the correct sort column
      @order = (params[:order] || "1").to_i - 1
      @options[:order] = columns[@order]
      if @instance.respond_to?(:children)
        if @options[:conditions]
          @options[:conditions] << " AND #{@model_class}.parent_id IS NULL"
        else
          @options[:conditions] = "#{@model_class}.parent_id IS NULL"
        end
      end
      @instances = @model.paginate(:conditions => @options[:conditions],:include => @options[:include],:page => params[:page],:per_page => Admin.per_page,:order => @options[:order])
    end
  end

  def bulk_add
    return admin_deny unless @bulk
    @css.push("3","4")
    @js.push("3")
    @title = "Bulk add #{@model_name.downcase}"
    @right = "bulk_add"
    @breadcrumb.push({:label => @title,:url => {:action => "bulk_add",:model => params[:model],:id => nil}})
    if request.post?
      errors = []
      fields = @bulk_fields.collect{|field| field[:name]}
      successes = 0
      for instance in params[:instances]
        unless instance.keys.all?{|key| instance[key].blank?}
          instance = @model.new(instance)
          if instance.save
            successes += 1
          else
            errors.push(instance.error_list(:string))
          end
        end
      end
      if successes > 0
        flash[:add] = "#{successes} #{(successes == 1 ? @model_name.singularize : @model_name).downcase} ha#{successes == 1 ? "s" : "ve"} been added!"
      end
      unless errors.empty?
        flash[:error] = "Something went wrong with #{errors.size} #{(errors.size == 1 ? @model_name.singularize : @model_name).downcase}."
        flash[:error_list] = errors.join("<br />")
      end
      redirect_to :action => "browse"
    end
  end

  def change_password
    if !params[:id] || (params[:id] && @user.admin_omnipotent?)
      if !params[:id]
        @instance = @user
        @breadcrumb.push({:label => "Change password",:url => {:action => "change_password"}})
      else
        @instance = User.find(:first,:conditions => ["users.active = ? AND users.id = ?",true,params[:id]])
        @breadcrumb.push({:label => @instance.class.to_s.pluralize,:url => {:action => "browse",:model => @instance.class.to_s.tableize}},{:label => @instance.name,:url => {:action => "edit",:model => "user",:id => @instance.id}},{:label => "Change password",:url => {:action => "change_password"}})
      end
      if request.post? && (params[:password] || @instance != @user)
        if @instance != @user || @instance = User.authenticate({:email => @instance.email,:password => params[:password]})
          if @instance.update_attributes(params[:instance])
            flash[:update] = "#{@instance == @user ? "Your" : @instance.name.possessive} password has been changed."
            redirect_to :action => "edit",:model => @instance.class.to_s.tableize.singularize,:id => @instance.id
          else
            flash[:error] = "The password could not be changed."
            flash[:error_list] = @instance.error_list
          end
        else
          flash[:error] = "The current password you entered was incorrect."
        end
      end
      @title = "Change Password"
      @css.push("3","4")
    else
      admin_deny
    end
  end

  def delete
    session[:delete_return] = request.env["HTTP_REFERER"] unless session[:delete_return]
    if params[:confirmed]
      case params[:confirmed].to_sym
      when :yes
        AdminAction.create(:user => @user,:action => "deleted",:model => @model_class.singularize.camelize,:model_id => @instance.id,:model_name => @instance.name)
        @instance.destroy
        unless request.xhr?
          flash[:delete] = "#{@instance.name} has been deleted."
        end
        if @external
          render :action => "delete_external"
        elsif request.xhr?
          render :text => "deleted"
        else
          redirect_to :action => "browse",:model => @model_class
        end
      when :no
        redirect_to session[:delete_return]
      end
      session[:delete_return] = nil
    end
    @title = "Delete \"#{@instance.name}\""
    @breadcrumb.push({:label => @title,:url => {:action => "delete",:model => params[:model],:id => @instance.id}})
  end

  def deleteall
    session[:delete_return] = request.env["HTTP_REFERER"] unless session[:delete_return]
    if params[:models]
      if action = params.keys.select{|key| !Admin.extensions[key.to_sym].nil?}[0]
        redirect_to :model => params[:model],:action => Admin.extensions[action.to_sym],:models => params[:models].join(",") and return
      elsif @options[:deletable]
        @model_count_name = "#{params[:models].size} #{(params[:models].size == 1 ? @model_name.singularize : @model_name).downcase}"
        if params[:confirmed] == "yes"
          for @instance in @model.find(params[:models])
            AdminAction.create(:user => @user,:action => "deleted",:model => @model_class.singularize.camelize,:model_id => @instance.id,:model_name => @instance.name)
            @instance.destroy
          end
          redirect_to session[:delete_return]
          session[:delete_return] = nil
          flash[:delete] = "#{@model_count_name} ha#{params[:models].size == 1 ? "s" : "ve"} been deleted."
          return
        elsif params[:confirmed] == "no"
          redirect_to session[:delete_return]
          session[:delete_return] = nil
          return
        end
        @title = "Delete #{@model_count_name}"
        @breadcrumb.push({:label => @title,:url => {:action => "browse",:model => @model_class}})
      else
        return admin_deny
      end
    else
      redirect_to :back
    end
  end

  def editor
    render :nothing => true and return unless ["image","images","hyperlink","video"].include?(params[:id])
    case params[:id]
    when "image"
      @photos = Photo.count > 60 ? "input" : Photo.find(:all,:order => "id ASC")
      @image_sizes = Base.image_sizes.keys.without(:admin_thumb)
    when "hyperlink"
      @pages = Page.tree(true).collect{|item| [item[0],url_for(item[1])]} if Rails.plugins[:cms]
    when "video"
      @videos = Video.find(:all,:conditions => ["videos.published = ? AND videos.processing = ?",true,false],:order => "videos.name ASC").collect{|video| [video.name,video.embed.gsub('"',"\"")]}
    end
    render :partial => "admin/editor/#{params[:id]}"
  end

  def edit
    if request.post?
      # render :text => params.inspect and return
      new_record = @instance.id.nil?
      @instance.attributes = params[:instance]
      if @instance.update_attributes(params[:instance])
        AdminAction.create(:user => @user,:action => new_record ? "added" : "updated",:model => @model_class.singularize.camelize,:model_id => @instance.id,:model_name => @instance.name)
        if !@json && !request.xhr?
          if new_record
            flash[:add] = "#{@model_name.singularize} \"#{@instance.name}\" has been added."
          else
            flash[:update] = "#{@model_name.singularize} \"#{@instance.name}\" has been saved."
          end
        end
        if @external
          render :action => "edit_external" and return
        elsif @json || request.xhr?
          render :text => "<body>#{@instance.to_json(:methods => @instance.respond_to?(:json) ? :json : nil)}</body>" and return
        elsif params[:return_to]
          redirect_to params[:return_to] and return
        elsif params[:return]
          redirect_to :action => "edit",:model => params[:model].singularize,:id => @instance.id,:anchor => params[:anchor] and return
        elsif params[:add_more]
          redirect_to :action => "edit",:model => params[:model].singularize,:id => nil and return
        else
          redirect_to :action => "browse",:model => params[:model].pluralize and return
        end
      else
        errors = @instance.errors.size
        flash[:error] = "There w#{errors == 1 ? "as" : "ere"} #{errors} error#{"s" if errors != 1} #{new_record ? "add" : "sav"}ing this #{@model_name.downcase.singularize}."
        flash[:error_list] = @instance.error_list
      end
    end
    @css.push("3","4")
    # @js.unshift("tinyMCE/tiny_mce")
    @js.push("4")
    @js.push(@model_class.singularize) if File.file?(File.join("#{RAILS_ROOT}","public","global","admin","js","#{@model_class.singularize}.js"))
    @right = "edit"
    if params[:id]
      @title = "Edit #{@model_name.singularize}"#{}" \"#{@instance.name}\""
    else
      @title = "Add a#{(@model_name[0,1].downcase =~ /[a,e,i,o]/).nil? ? "" : "n"} #{@model_name.singularize.downcase}"
      @breadcrumb.push({:label => @title,:url => {:action => "edit",:model => params[:model],:id => nil}})
    end
    reflections = @model.admin_reflections.compact.collect{|reflection| @model.reflections[reflection]}
    @has_many = reflections.compact.select{|reflection| reflection.macro == :has_many}
    @many_to_many = reflections.compact.select{|reflection| reflection.macro == :has_and_belongs_to_many}
    if @model_class == "users" && !@user.admin_omnipotent?
      @many_to_many.delete_if{|reflection| reflection.name == :admin_roles}
    end
  end

  def export
    require_library_or_gem "fastercsv" unless Object.const_defined?(:FasterCSV)
    columns = @model.columns.collect{ |c| c.name.to_sym }
    csv_string = FasterCSV.generate do |csv|
      csv << columns
      @model.find(:all).each do |record|
        csv << columns.collect{ |c| record.send(c) }
      end
    end
    send_data(csv_string, :type => 'text/csv',
      :disposition => "attachment; filename=#{@model.name}.csv")
  end

  def filter
    queryset = @model.filter
    if params[:filter]
      params[:filter].delete_if{|key,value| value.is_a?(String) && value.gsub(/^[ \t\n]|[ \t\n]$/,"").blank?}
      for key,value in params[:filter]
        filter = @filters.select{|filter| filter[:name] == key.to_sym}[0]
        if filter
          if filter[:combine]
            nqueryset = @model.filter
            for field in filter[:combine]
              nqueryset | @model.filter("#{field}__like" => value)
            end
            queryset & nqueryset
          elsif value.is_a?(Hash) && value["min"] && value["max"]
            queryset.filter("#{key}__range" => [value["min"],value["max"]])
          else
            case filter[:type]
            when :string
              queryset.filter("#{key}__like" => value)
            when :boolean
              queryset.filter(key => value == "true")
            when :belongs_to,:has_and_belongs_to_many,:has_many,:has_one
              queryset.filter("#{key}__in" => value)
            else
              render :text => "unknown type on filter: #{filter.inspect}" and return
            end
          end
        end
      end
    end
    instances = @model.paginate(:conditions => queryset.conditions.empty? ? nil : queryset.conditions,:include => [@options[:include],queryset.includes].flatten.compact.uniq,:order => @options[:order],:page => params[:page],:per_page => Admin.per_page)
    render :partial => "browse_table",:locals => {:class_name => @model_class,:external => false,:instances => instances,:model_name => @model_name,:options => @options,:order => nil,:order_sort => nil,:sortable => @instance.respond_to?(:move_to_top),:tree => @instance.respond_to?(:children)}
  end

  def help
    if request.xhr?
      render :partial => "admin/right/help"
    end
  end

  def help_section
    render :partial => "admin/right/help_section"
  rescue
    render :partial => "admin/right/help_section_unavailable"
  end

  def import
    return deny unless @model.admin_importable
    require "fastercsv"
    @title = "Import #{@model_name.downcase}"
    @right = "dashboard"
    @breadcrumb.push({:label => "Import",:url => {:action => "import",:model => @model_class,:id => nil}})
    if request.post?
      if params[:file] && params[:file].respond_to?(:read)
        case File.extname(params[:file].original_filename)
        when ".xml"
          @instances = XmlSimple.xml_in(params[:file].read)
          raise "#{@instances.inspect}"
        when ".csv"
          @instances = FasterCSV.parse(params[:file].read)
          @instances.delete_if{|instance| instance == [] || instance.all?{|value| value.blank?}}
          @css.push("4")
          @title << ": Select columns"
          @columns = @model.columns.select{|column| column.name !~ /_id$/ && column.name !~ /^(id|type)$/}.collect{|column| [column.name.humanize,column.name]}
          @columns += @model.admin_import_columns.collect{|column| [column.to_s.humanize,column]}
          @columns.unshift(["(none)",""])
          render :action => "import_csv" and return
        else
          flash[:error] = "Could not determine this file's type. Please upload a CSV or XML file." and return
        end
      elsif params[:columns] && params[:instances]
        successes = 0
        failures = 0
        params[:columns].delete_if{|key,value| value.blank?}
        for key,instance in params[:instances]
          attributes = {}
          for column,value in params[:columns]
            attributes[value] = instance[column]
          end
          if @model.create(attributes).new_record?
            failures += 1
          else
            successes += 1
          end
        end
        flash[:error] = "#{failures} #{failures == 1 ? @model_name.downcase.singularize : @model_name.downcase} could not be imported" unless failures == 0
        flash[:add] = "#{successes} #{successes == 1 ? @model_name.downcase.singularize : @model_name.downcase} were imported"
        redirect_to :action => "browse"
      else
        flash[:error] = "You must upload a file with importable data"
      end
    end
  end

  def index
    # @title = "My Dashboard"
    @css.push("records")
    @right = "dashboard"
  end

  def list
    if @instance.respond_to?(params[:reflection])
      reflection = @model.reflections[params[:reflection].to_sym]
      model_class = reflection.class_name.constantize
      class_name = model_class.name.tableize
      model_name = model_class.admin_name
      reflection_name = reflection.name.to_s
      if params[:many] == "yes"
        render :partial => "many_to_many",:locals => {:class_name => class_name,:model_class => model_class,:model_name => model_name,:reflection_name => reflection_name,:selected => @instance.send(reflection.name),:size => model_class.count}
      else
        instance = model_class.new
        render :partial => "browse_table",:locals => {:class_name => class_name,:external => true,:model_name => model_name,:instances => @instance.send(reflection_name),:options => model_class.admin_options,:order => nil,:order_sort => nil,:sortable => instance.respond_to?(:move_to_top),:tree => instance.respond_to?(:children)}
      end
    else
      render :text => "Error!"
    end
  end

  def notification
    if params[:id] && notification = Notification.find(:first,:conditions => ["notifications.id = ?",params[:id]])
      if @user.has_admin_role?(notification.admin_role.name)
        notification.notification_views.find_or_create_by_user_id(@user.id)
        if params[:ignore]
          redirect_to :back
        else
          redirect_to notification.view_url
        end
      else
        admin_deny
      end
    else
      admin_deny
    end
  end

  def records_css
    headers["Content-Type"] = "text/css"
    render :partial => "admin/skins/#{@user.admin_skin.downcase.gsub(" ","_")}_css",:layout => false
  end

  def reports
    if @user.admin_omnipotent?
      if request.post? || request.xhr?
        render :text => "filter results:\n\n#{params.inspect}"
      end
      @css.push("3","4")
      @js.push("reports")
      @title = "#{@model_name} Reporting"
      @right = "reporting"
      @breadcrumb.push({:label => "Reporting",:url => {:action => "reports",:model => @model_class,:id => nil}})
    end
  end

  def reorder
    params[:records].each_with_index do |record_id,index|
      @model.update(record_id,:position => index+1)
    end
    render :text => "true"
  end

  def search
    @instances = @model.filter
    for field in @model.admin_search_fields
      term = @model.filter
      for split in params[:value].split(" ")
        term.filter("#{field}__contains" => split)
      end
      @instances | term
    end
    @instances = @instances.find(:all)
    # logger.warn("\n\n" + @instances.collect{|instance| "#{instance.id}: #{instance.name}"}.join("\n")+"\n\n")
    if request.xhr?
      render :layout => false
    else
      render :action => "browse"
    end
  end

  def settings
    if @user.admin_omnipotent?
      if request.post?
        if Configuration.update(params[:configuration].update(:self_advertise => params[:configuration][:self_advertise] != "0"))
          flash[:update] = "Your site configuration has been saved."
          Configuration.save
        else
          flash[:error] = "Your site configuration could not be saved. You must supply a site name."
        end
      end
      @css.push("3","4")
      @title = "Settings"
      @right = "dashboard"
      @breadcrumb.push({:label => "Settings",:url => {:action => "settings",:id => nil}})
      @instances = AdminRole.find(:all,:order => "omnipotent DESC,name ASC")
    else
      admin_deny
    end
  end

  def setup
    if Configuration.first_load
      @css.push("3")
      @title = "Welcome to your new #{Admin.app_name} installation!"
      @right = "setup"
      if request.post?
        if Configuration.update(params[:configuration])
          @user = User.new(params[:user].update({:admin => true}))
          if @user.valid?
            Configuration.save
            @user.save
            @user.admin_roles = [AdminRole.create(:name => "Administrator",:omnipotent => true)]
            if Rails.plugins[:cms]
              role = AdminRole.create(:name => "Content Manager")
              role.admin_permissions.create(:model => "article")
              role.admin_permissions.create(:model => "file_store")
              role.admin_permissions.create(:model => "page")
              role.admin_permissions.create(:model => "photo")
            end
            if Rails.plugins[:blog]
              role = AdminRole.create(:name => "Blogger")
              role.admin_permissions.create(:model => "blog_post",:must_own => true)
              role.admin_permissions.create(:model => "category")
              role.admin_permissions.create(:model => "comment")
            end
            if Rails.plugins[:store]
              role = AdminRole.create(:name => "Store Manager")
              role.admin_permissions.create(:model => "product")
              role.admin_permissions.create(:model => "order")
            end
            session[:configuration] = true
            session[:user] = Base.store_in_session ? @user : @user.id
            flash[:update] = "Your site has been successfully configured!"
            redirect_to :action => "index" and return false
          else
            flash[:error] = "Your user credentials could not be saved..."
            flash[:error_list] = @user.error_list
          end
        else
          flash[:error] = "Your configuration could not be saved. You must supply a site name."
        end
      end
    else
      redirect_to :action => "settings" and return false
    end
  end

  def set_session_var
    if params[:id] && params[:id] != user
      session[params[:id]] = params[:value]
    end
  end

  def widget
    if params[:id]
      widget = @user.admin_widgets.find(:first,:conditions => ["admin_widgets.widget = ?",params[:id]])
      widget.update_attribute(:collapsed,params[:collapsed] == "yes")
    end
    if request.xhr?
      render :nothing => true
    end
  end

  private
  def admin_deny
    @breadcrumb.push({:label => "File Not Found"})
    return deny(:status => 401)
  end

  def admin_layout
    request.user_agent.include?("iPhone") ? "admin_iphone" : "admin"
  end

  def more_context_data
    @admin_url = Base.urls["admin"]
    @breadcrumb = []#{:label => "My Dashboard",:url => {:action => "index", :id => nil}}]
    @external = params[:external] == "yes"
    @json = params[:json] == "yes"
    if @external
      @css.push("2")
    elsif !request.xhr? && @user
      @models = []
      Admin.models.each{|model| model_class = model.constantize; activerecord = model_class.new.is_a?(ActiveRecord::Base); model_name = model_class.admin_name; @models.push({:action => activerecord ? nil : model_class.admin_url,:activerecord => activerecord,:name => model_name,:permission => @user.admin_omnipotent? ? true : @user.admin_permission(model[:url]),:title => activerecord ? "Add a#{"n" if model_name[0,1].downcase =~ /(a|e|i|o)/} #{model_name.downcase.singularize}" : model_class.admin_add_title,:url => model.tableize})}.uniq
      @models = @models.delete_if{|model| !model[:permission]}.sort{|a,b| a[:name] <=> b[:name]}
    end
  end

  def set_filters
    @filters = @instance.admin_filters(params[:action] == "browse" && !request.xhr?)
    true
  end

  def set_instance
    if params[:id]
      return admin_deny unless @instance = @model.find_by_id(params[:id],:conditions => @options[:conditions],:include => @options[:include])
      @breadcrumb.push({:label => @instance.name,:url => {:action => "edit",:model => params[:model],:id => @instance.id}})
    elsif params[:action] =~ /(browse|bulk_add|edit|filter|reports)/
      @instance = @model.new
    end
    @js.unshift("http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{Configuration.google_maps_key}") if @model.admin_maps
    case params[:action].to_sym
    when :edit
      @instance.user_id = @user.id if @instance.respond_to?(:user_id) && @instance.user_id.nil?
      if request.get?
        for key in params.without(:controller,:action,:id).keys
          @instance.send("#{key}=",params[key]) if @instance.respond_to?("#{key}=")
        end
        @instance.send(:defaults) if @instance.new_record? && @instance.respond_to?(:defaults)
      end
      @fields = @instance.admin_fields(nil,@ownership_required)
    when :bulk_add
      @bulk_fields = @model.admin_bulk_fields
    end
  end

  def set_model
    @model = params[:model].singularize.camelize.constantize
    @model_name = @model.admin_name.pluralize
    @model_class = params[:model].tableize
    if (params[:action] == "edit" && params[:model] == "user" && params[:id] == @user.id.to_s) || @user.admin_omnipotent? || (permission = @user.admin_permission(@model_class)) || (!Admin.models.include?(@model.name) && !Admin.protected_models.include?(@model.name))
      @options = @model.admin_options
      @ownership_required = !@user.admin_omnipotent? && permission && permission.must_own
      if @ownership_required
        if @options[:conditions]
          @options[:conditions][0] << " AND user_id = ?"
          @options[:conditions].push(@user.id)
        else
          @options[:conditions] = ["user_id = ?",@user.id]
        end
      end
      @breadcrumb.push({:label => @model_name,:url => {:action => "browse",:model => @model_class}})
      @bulk = @model.admin_bulk_fields && !@model.admin_bulk_fields.empty?
      return true
    else
      return admin_deny
    end
  rescue NameError
    return admin_deny
  end

  def start_context_data
    if params[:_token] && @user = AuthToken.validate(params[:_token])
      session[:user] = Base.store_in_session ? @user : @user.id
    end
    # if Base.find_user_options[:include]
    #   Base.find_user_options[:include].push(:admin_roles,:admin_actions,:admin_widgets)
    # else
    #   Base.find_user_options[:include] = [:admin_actions,:admin_roles,:admin_widgets]
    # end
    load_context_data
    # Base.find_user_options[:include] -= [:admin_actions,:admin_roles,:admin_widgets]
    @css = ["0","1","3"]
    @js = ["0","1"]
  end
end
