require File.dirname(__FILE__) + '/../test_helper'
class AppControllerTest < ActionController::TestCase
  def setup
    @controller = AppController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  # def test_001_index
  #   get :index,{},{:user => 1}
  #   assert_response 200
  #   assert_not_nil assigns["user"]
  #   assert_equal({:controller => "app",:action => "index",:id => nil},session[:return])
  # end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
  end

  # def test_003_set_session_var
  #   # TODO: Fix this for XHR testing as well as adding a request.env["HTTP_REFERER"]
  #   get :set_filter_var,{:id => "test_session_var",:on => "true"},{:user => 1}
  #   assert_response :redirected
  #   get :set_filter_var,{:id => "test_session_var",:on => "true"}
  #   assert_response 404
  #   assert_template "main/404"
  # end
end