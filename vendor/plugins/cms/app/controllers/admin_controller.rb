class AdminController < ApplicationController
  def email_compose
    @title = "Compose an e-mail"
    @css.push("3","4")
    @js.push("4")
    @breadcrumb.push({:label => @title})
  end

  def expire
    key = @instance.attributes.keys.first
    @instance.update_attributes(key => @instance.attributes[key])
    flash[:delete] = "The cached copy of \"#{@instance.name}\" has been deleted"
    redirect_to :action => "edit"
  end

  def mailing_list
    if request.post?
      if params[:mailing_list] && mailing_list = MailingList.find(:first,:conditions => ["name_based_models.id = ?",params[:mailing_list]],:include => [:mailing_list_users])
        new_users = 0
        old_users = 0
        for user in params[:models].split(",")
          mailing_list_user = mailing_list.mailing_list_users.find_or_initialize_by_user_id(user)
          if mailing_list_user.new_record?
            new_users += 1
            mailing_list_user.save
          else
            old_users += 1
          end
          flash[:add] = "#{new_users} #{(new_users == 1 ? @model_name.singularize : @model_name).downcase} have been added" if new_users > 0
          flash[:error] = "#{old_users} #{(old_users == 1 ? @model_name.singularize : @model_name).downcase} could not be added because they already belong to this list" if old_users > 0
          redirect_to :action => "edit",:model => "mailing_list",:id => mailing_list.id and return
        end
      else
        flash[:error] = "Please select a mailing list"
      end
    end
    @users = User.find(params[:models].split(","))
    @title = "Add #{@users.size} #{(@users.size == 1 ? @model_name.singularize : @model_name).downcase} to a mailing list"
    @breadcrumb.push({:label => "Add to mailing list"})
    @right = "dashboard"
    @mailing_lists = MailingList.find(:all,:order => ["name"])
  end

  def mailing_list_send
    @title = "Send an E-mail to #{@instance.name}"
    @breadcrumb.push({:label => "Send",:url => {:action => "mailing_list_send"}})
  end

  def newsletter_send
    flash[:notice] = "This newsletter has been sent"
    redirect_to :back
  end

  def preview
    if @instance.is_a?(Page)
    elsif @instance.is_a?(Newsletter)
      @instance.deliver(@user)
      flash[:notice] = "A preview e-mail has been sent to #{@user.email}"
      redirect_to :action => "edit"
    end
  end
end