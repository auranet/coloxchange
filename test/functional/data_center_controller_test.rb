require File.dirname(__FILE__) + '/../test_helper'
class DataCenterControllerTest < ActionController::TestCase
  fixtures :data_centers,:users

  def setup
    @controller = DataCenterController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["data_centers"]
    assert_equal session[:return],{:controller => "data_center",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["data_centers"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "data_center/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "data_center/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = DataCenter.count
    post :edit,{:data_center => {:name => "Test Data Center #2",:city => "Baltimore",:state => "MD"}},{:return => {:controller => "data_center",:action => "index"},:user => 1}
    assert_response :redirect
    assert_redirected_to session[:return]
    assert_equal DataCenter.count,count+1
  end

  def test_005_add_invalid
    count = DataCenter.count
    post :edit,{:data_center => {}},{:user => 1}
    assert_template "data_center/edit"
    assert_equal DataCenter.count,count
  end

  def test_006_delete
    count = DataCenter.count
    get :delete,{:id => 1},{:return => {:controller => "data_center",:action => "index"},:user => 1}
    assert_not_nil assigns["data_center"]
    assert_equal DataCenter.count,count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "data_center",:action => "index"},:user => 1}
    assert_equal DataCenter.count,count-1
    assert_response :redirect
    hash = {:controller => "data_center",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = DataCenter.count
    assert_equal DataCenter.find(1).city,"Denver"
    post :edit,{:id => 1,:data_center => {:name => "Test Data Center",:city => "Baltimore",:state => "MD"}},{:return => {:controller => "data_center",:action => "index"},:user => 1}
    assert_equal DataCenter.find(1).city,"Baltimore"
    hash = {:controller => "data_center",:action => "index"}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal DataCenter.count,count
  end

  def test_008_edit_invalid
    count = DataCenter.count
    assert_equal DataCenter.find(1).city,"Denver"
    post :edit,{:id => 1,:data_center => {:name => "Test Data Center",:city => "",:state => ""}},{:return => {:controller => "data_center",:action => "index"},:user => 1}
    assert_equal DataCenter.find(1).city,"Denver"
    assert_response 200
    assert_template "data_center/edit"
    assert_equal DataCenter.count,count
  end

  def test_009_view
    count = DataCenter.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["data_center"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "data_center/view"
    assert_equal DataCenter.count,count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end
end