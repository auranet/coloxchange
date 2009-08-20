require File.dirname(__FILE__) + '/../test_helper'
class CompanyControllerTest < ActionController::TestCase
  fixtures :companies,:users
  def setup
    @controller = CompanyController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["companies"]
    assert_equal session[:return],{:controller => "company",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["companies"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "company/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "company/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = Company.count
    post :edit,{:company => {:name => "Test #2"}},{:return => {:controller => "company",:action => "index"},:user => 1}
    assert_equal count+1,Company.count
    assert_response :redirect
    return_url = {:action => "view",:id => assigns["company"].id}
    assert_redirected_to return_url
  end

  def test_005_add_invalid
    count = Company.count
    post :edit,{:company => {}},{:user => 1}
    assert_template "company/edit"
    assert_equal count,Company.count
  end

  def test_006_delete
    count = Company.count
    get :delete,{:id => 1},{:return => {:controller => "company",:action => "index"},:user => 1}
    assert_not_nil assigns["company"]
    assert_equal count,Company.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "company",:action => "index"},:user => 1}
    assert_equal count-1,Company.count
    assert_response :redirect
    hash = {:controller => "company",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = Company.count
    assert_equal "20 Odd Years",Company.find(1).name
    post :edit,{:id => 1,:company => {:name => "Test"}},{:return => {:controller => "company",:action => "index"},:user => 1}
    assert_equal "Test",Company.find(1).name
    hash = {:controller => "company",:action => "index"}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal count,Company.count
  end

  def test_008_edit_invalid
    count = Company.count
    assert_equal "20 Odd Years",Company.find(1).name
    post :edit,{:id => 1,:company => {:name => ""}},{:return => {:controller => "company",:action => "index"},:user => 1}
    assert_equal "20 Odd Years",Company.find(1).name
    assert_response 200
    assert_template "company/edit"
    assert_equal count,Company.count
  end

  def test_009_view
    count = Company.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["company"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "company/view"
    assert_equal count,Company.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end

  def test_011_filtering
    get :index,{:filter => {"name" => "20 Odd"}},{:user => 1}
    assert_response 200
    assert_equal 1,assigns["companies"].size
    get :index,{:filter => {"name" => "Sasser Inte"}},{:user => 1}
    assert_response 200
    assert_equal 1,assigns["companies"].size
    get :index,{:filter => {"name" => "Foo McBar"}},{:user => 1}
    assert_response 200
    assert assigns["companies"].empty?
  end

  def test_012_autocomplete
    get :autocomplete,{:value => "20 Odd"},{:user => 1}
    assert_response 200
    assert_template "company/autocomplete"
    assert_not_nil assigns["companies"]
    assert_equal 1,assigns["companies"].size
    get :autocomplete,{:value => "Sasser Foo"},{:user => 1}
    assert_response 200
    assert_template "company/autocomplete"
    assert_not_nil assigns["companies"]
    assert assigns["companies"].empty?
    get :autocomplete,{},{:user => 1}
    assert_response 200
    assert_template "company/autocomplete"
    assert_not_nil assigns["companies"]
    assert assigns["companies"].empty?
  end
end