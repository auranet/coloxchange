class MainController < ApplicationController
  append_before_filter :load_admin_context_data

  protected
  def load_admin_context_data
    if @user && @user.admin?
      @css.push("../global/admin/css/6")
      @admin_top = true
    end
  end
end