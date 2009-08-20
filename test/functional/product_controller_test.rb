require File.dirname(__FILE__) + '/../test_helper'
class ProductControllerTest < ActionController::TestCase
  fixtures :products,:users
  def setup
    @controller = ProductController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["products"]
    assert_equal session[:return],{:controller => "product",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["products"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "product/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "product/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = Product.count
    post :edit,{:product => {:name => "Test #2"}},{:return => {:controller => "product",:action => "index"},:user => 1}
    assert_equal count+1,Product.count
    assert_response :redirect
    return_url = {:action => "view",:id => assigns["product"].id}
    assert_redirected_to return_url
  end

  def test_005_add_invalid
    count = Product.count
    post :edit,{:product => {}},{:user => 1}
    assert_template "product/edit"
    assert_equal count,Product.count
  end

  def test_006_delete
    count = Product.count
    get :delete,{:id => 1},{:return => {:controller => "product",:action => "index"},:user => 1}
    assert_not_nil assigns["product"]
    assert_equal count,Product.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "product",:action => "index"},:user => 1}
    assert_equal count-1,Product.count
    assert_response :redirect
    hash = {:controller => "product",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = Product.count
    assert_equal "Name",Product.find(1).name
    post :edit,{:id => 1,:product => {:name => "Test"}},{:return => {:controller => "product",:action => "index"},:user => 1}
    assert_equal "Test",Product.find(1).name
    hash = {:controller => "product",:action => "index"}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal count,Product.count
  end

  def test_008_edit_invalid
    count = Product.count
    assert_equal "Name",Product.find(1).name
    post :edit,{:id => 1,:product => {:name => ""}},{:return => {:controller => "product",:action => "index"},:user => 1}
    assert_equal "Name",Product.find(1).name
    assert_response 200
    assert_template "product/edit"
    assert_equal count,Product.count
  end

  def test_009_view
    count = Product.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["product"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "product/view"
    assert_equal count,Product.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end
end