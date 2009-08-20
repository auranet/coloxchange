require File.dirname(__FILE__) + '/../test_helper'
class OrderControllerTest < ActionController::TestCase
  fixtures :orders,:term_lengths,:users
  def setup
    @controller = OrderController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["orders"]
    assert_equal session[:return],{:controller => "order",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["orders"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "order/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "order/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = Order.count
    post :edit,{:order => {:name => "Test #2",:nrc => 15000,:mrc => 4000,:term_length => TermLength.create(:length => 2,:term => "Months")}},{:return => {:controller => "order",:action => "index"},:user => 1}
    assert_equal count+1,Order.count
    assert_response :redirect
    return_url = {:controller => "order",:action => "view",:id => assigns["order"].id}
    assert_redirected_to return_url
  end

  def test_005_add_invalid
    count = Order.count
    post :edit,{:order => {}},{:user => 1}
    assert_template "order/edit"
    assert_equal count,Order.count
  end

  def test_006_delete
    count = Order.count
    get :delete,{:id => 1},{:return => {:controller => "order",:action => "index"},:user => 1}
    assert_not_nil assigns["order"]
    assert_equal count,Order.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "order",:action => "index"},:user => 1}
    assert_equal count-1,Order.count
    assert_response :redirect
    hash = {:controller => "order",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = Order.count
    assert_equal "Name",Order.find(1).name
    post :edit,{:id => 1,:order => {:name => "Test"}},{:return => {:controller => "order",:action => "index"},:user => 1}
    assert_equal "Test",Order.find(1).name
    hash = {:controller => "order",:action => "index"}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal count,Order.count
  end

  def test_008_edit_invalid
    count = Order.count
    assert_equal "Name",Order.find(1).name
    post :edit,{:id => 1,:order => {:name => "Test",:mrc => nil}},{:return => {:controller => "order",:action => "index"},:user => 1}
    assert_equal "Name",Order.find(1).name
    assert_response 200
    assert_template "order/edit"
    assert_equal count,Order.count
  end

  def test_009_view
    count = Order.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["order"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "order/view"
    assert_equal count,Order.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end
end