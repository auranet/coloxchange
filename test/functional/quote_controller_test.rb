require File.dirname(__FILE__) + '/../test_helper'
class QuoteControllerTest < ActionController::TestCase
  fixtures :addresses,:quotes,:users
  def setup
    @controller = QuoteController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["quotes"]
    assert_equal session[:return],{:controller => "quote",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["quotes"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "quote/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "quote/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = Quote.count
    post :edit,{:quote => {:name => "Test #2",:address_id => 1,:manager_id => 1,:contact_id => 3,:product_ids => [1]}},{:return => {:controller => "quote",:action => "index"},:user => 1}
    assert_equal count+1,Quote.count
    assert_response :redirect
    return_url = {:action => "data_centers",:id => assigns["quote"].id}
    assert_redirected_to return_url
  end

  def test_005_add_invalid
    count = Quote.count
    post :edit,{:quote => {:name => "Test #3",:address_id => nil,:manager_id => 2,:contact_id => nil,:product_ids => [1]}},{:user => 1}
    assert_template "quote/edit"
    assert_equal count,Quote.count
  end

  def test_006_delete
    count = Quote.count
    get :delete,{:id => 1},{:return => {:controller => "quote",:action => "index"},:user => 1}
    assert_not_nil assigns["quote"]
    assert_equal count,Quote.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "quote",:action => "index"},:user => 1}
    assert_equal count-1,Quote.count
    assert_response :redirect
    hash = {:controller => "quote",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = Quote.count
    assert_equal "Name",Quote.find(1).name
    post :edit,{:id => 1,:quote => {:name => "Test",:product_ids => [1]}},{:return => {:controller => "quote",:action => "index"},:user => 1}
    assert_equal "Test",Quote.find(1).name
    hash = {:action => "data_centers",:id => assigns["quote"].id}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal count,Quote.count
  end

  def test_008_edit_invalid
    count = Quote.count
    assert_equal "Name",Quote.find(1).name
    post :edit,{:id => 1,:quote => {:name => ""}},{:return => {:controller => "quote",:action => "index"},:user => 1}
    assert_equal "Name",Quote.find(1).name
    assert_response 200
    assert_template "quote/edit"
    assert_equal count,Quote.count
  end

  def test_009_view
    count = Quote.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["quote"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "quote/view"
    assert_equal count,Quote.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end
end