class MainController < ApplicationController
  def login
    if @user.nil?
      @title = "Log in"
      if request.post?
        if user = User.authenticate(params[:user])
          session[:user] = Base.store_in_session ? user : user.id
          redirect_to return_url || Base.after_login_url and return false
        else
          flash[:error] = Base::Messages.login_failed
        end
      end
      render :template => "main/login" and return false
    else
      @title = "Logged in"
      render :template => "main/login_blocked"
    end
  end

  def logout
    @user = nil
    session[:return] = nil
    session[:user] = nil
    flash[:notice] = Base::Messages.logout_successful
    redirect_to Base.after_logout_url
  end

  def lost_password
    if request.post?
      if !params[:email].blank? && user = User.find(:first,:conditions => ["users.email = ?",params[:email]])
        user.reset_password
        flash[:notice] = "Your password has been reset"
        render :text => "A new password has been e-mailed to #{params[:email]}",:layout => true
      elsif !params[:email].blank?
        flash[:error] = "A user account with that e-mail does not exist."
      else
        flash[:error] = "You must enter an e-mail address"
      end
    end
    @title = "Reset password"
  end
end