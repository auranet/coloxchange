module Base
  module Application
    def self.included(base)
      base.extend ClassMethods
      base.send :include,InstanceMethods
      base.send :after_filter,:cleanup_context_data
      base.send :prepend_before_filter,:load_context_data
    end

    module ClassMethods
      def action_method_names
        action_methods.to_a.without("clickthrough","context_data","page")
      end
    end

    module InstanceMethods
      private
      def cleanup_context_data
        if Base.store_in_session
          session[:user] = @user
        end
      end

      def click(record)
        record.clicks.create(:ip => request.env["HTTP_X_REAL_IP"] || request.env["REMOTE_ADDR"],:new_keywords => session[:keywords],:referer => session[:referer],:user => @user)
      end

      def deny(options = {})
        options = {:title => "404 File Not Found",:status => 404,:template => "main/404"}.update(options)
        @title = options[:title]
        @page = nil
        render(:template => options[:template],:status => options[:status]) and return false
      end

      def load_context_data
        if @ssl && RAILS_ENV == 'production' && !request.ssl?
          redirect_to "https://#{request.env["HTTP_X_FORWARDED_HOST"]}#{request.env["REQUEST_PATH"]}" and return false
        elsif !@ssl && request.ssl?
          redirect_to "http://#{request.env["HTTP_X_FORWARDED_HOST"]}#{request.env["REQUEST_PATH"]}" and return false
        end
        @css = ['screen', 'print']
        @js = [RAILS_ENV == 'production' ? 'http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js' : 'libraries', 'application']
        if Configuration.first_load && Rails.plugins[:admin] && params[:action] != "setup"
          redirect_to :controller => "admin",:action => "setup" and return false
        else
          @meta_keywords = Configuration.meta_keywords
          @meta_description = Configuration.meta_description
          @meta_author = Configuration.meta_author
          @meta_copyright = Configuration.meta_copyright
        end
        if session[:referer].nil?
          if request.env["HTTP_REFERER"] && request.env["HTTP_REFERER"] !~ /^#{url_for(:controller => "main",:action => "index")}/
            session[:referer] = request.env["HTTP_REFERER"]
            if session[:referer] =~ /(google|msn|yahoo|\?q=)/
              session[:keywords] = []
              for keyword in session[:referer].split(/\?[q|p]=/)[1].split("&")[0].split(/(\%20|\+)/).without("+")
                keywords = keyword.strip.downcase
                if !["the","a","in","for"].include?(keyword)
                  keyword = Keyword.find_or_initialize_by_name(keyword.strip.downcase) 
                  keyword.update_attribute(:hits,keyword.hits + 1)
                  session[:keywords].push(keyword.id)
                end
              end
            end
          else
            session[:referer] = false
          end
        end
        if session[:user]
          @user = Base.store_in_session ? session[:user] : User.find(:first,Base.find_user_options.update({:conditions => ["users.active = ? AND users.id = ?",true,session[:user]]}))
        end
        self.send "#{params[:action]}_context" if self.respond_to?("#{params[:action]}_context")
        if Rails.plugins[:cms] && !request.xhr? && !CMS.skip_snippet_controllers.include?(params[:controller].to_sym) && ((params[:action] == "page" && params[:id].blank?) || params[:action] != "page") && (params[:format].blank? || params[:format] == 'html')
          build_snippets(SnippetAttachment.find(:all,:conditions => ["snippet_attachments.controller = ? AND snippet_attachments.action = ?",params[:controller],params[:action]],:include => [:snippet]))
        end
      end

      protected
      def require_admin
        if require_user
          unless @user.admin?
            flash[:error] = Base::Messages.admin_required
            render :template => "main/admin_required" and return false
          end
          if @user.change_password && params[:controller] == "admin" && params[:action] != "change_password"
            @title = "Password Change Required"
            @css.push("forms","tables")
            flash[:update] = "You must change your password before continuing"
            render :template => "admin/change_password" and return false
          end
        else
          return false
        end
      end

      def require_ssl
        @ssl = true
      end

      def require_user
        if !@user
          @title = "Log in"
          session[:return] = request.env["REQUEST_URI"]
          flash[:error] = Base::Messages.user_required
          respond_to do |wants|
            wants.html { render :template => "main/login",:status => 401 and return false }
            wants.xml { render :template => "main/auth_token_invalid",:status => 404 }
          end
        end
        true
      end

      def require_xhr
        return deny unless request.xhr?
      end

      def rescue_action_in_public(exception)
        case exception
        when ActiveRecord::RecordNotFound
          deny(:status => 404, :template => "main/404", :title => "404 Not Found")
        else
          deny(:status => 500, :template => "main/500", :title => "500 Internal Server Error")
        end
      end

      def return_url
        session[:return]
      end

      private
      def build_snippets(snippet_attachments)
        @snippets ||= {}
        for area in [CMS.content_areas.keys,CMS.snippet_positions.keys].flatten.uniq
          snippets = snippet_attachments.select{|snippet_attachment| snippet_attachment.area.to_sym == area}.collect{|snippet_attachment| snippet_attachment.snippet.body}
          if @snippets[area]
            @snippets[area].concat(snippets)
          else
            @snippets[area] = snippets
          end
          @snippets[area].push(@page.section(area)) if @page
          @snippets[area] = @snippets[area].compact
        end
      end
    end
  end
end
