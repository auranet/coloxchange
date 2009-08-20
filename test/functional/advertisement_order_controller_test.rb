require File.dirname(__FILE__) + '/../test_helper'
class AdvertisementOrderControllerTest < ActionController::TestCase
  fixtures :advertisements,:users
  def setup
    @controller = AdvertisementOrderController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["advertisements"]
    assert_equal session[:return],{:controller => "advertisement",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["advertisements"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "advertisement/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "advertisement/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = AdvertisementOrder.count
    post :edit,{:advertisement => {:name => "Test #2",:manager_id => 2,:contact_id => 3,:price => 15000}},{:return => {:controller => "advertisement",:action => "index"},:user => 1}

    assert_equal count+1,AdvertisementOrder.count
    assert_response :redirect
    assert_redirected_to session[:return]
  end

  def test_005_add_invalid
    count = AdvertisementOrder.count
    post :edit,{:advertisement => {}},{:user => 1}
    assert_template "advertisement/edit"
    assert_equal count,AdvertisementOrder.count
  end

  def test_006_delete
    count = AdvertisementOrder.count
    get :delete,{:id => 1},{:return => {:controller => "advertisement",:action => "index"},:user => 1}
    assert_not_nil assigns["advertisement"]
    assert_equal count,AdvertisementOrder.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "advertisement",:action => "index"},:user => 1}
    assert_equal count-1,AdvertisementOrder.count
    assert_response :redirect
    hash = {:controller => "advertisement",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = AdvertisementOrder.count
    assert_equal AdvertisementOrder.find(1).name,"Name"
    post :edit,{:id => 1,:advertisement => {:name => "Test"}},{:return => {:controller => "advertisement",:action => "index"},:user => 1}
    assert_equal AdvertisementOrder.find(1).name,"Test"
    hash = {:controller => "advertisement",:action => "index"}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal count,AdvertisementOrder.count
  end

  def test_008_edit_invalid
    count = AdvertisementOrder.count
    assert_equal AdvertisementOrder.find(1).name,"Name"
    post :edit,{:id => 1,:advertisement => {:name => "Test",:manager_id => nil}},{:return => {:controller => "advertisement",:action => "index"},:user => 1}
    assert_equal AdvertisementOrder.find(1).name,"Name"
    assert_response 200
    assert_template "advertisement/edit"
    assert_equal count,AdvertisementOrder.count
  end

  def test_009_view
    count = AdvertisementOrder.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["advertisement"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "advertisement/view"
    assert_equal count,AdvertisementOrder.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end

  def test_011_filtering
    get :index,{:filter => {"name" => "Test Advertisement"}},{:user => 1}
    assert_response 200
    assert_equal 1,assigns["advertisements"].size
    get :index,{:filter => {"name" => "Test Advertisement",:status => [0]}},{:user => 1}
    assert_response 200
    assert_equal 1,assigns["advertisements"].size
    get :index,{:filter => {"name" => "Test Advertisement",:status => [1]}},{:user => 1}
    assert_response 200
    assert assigns["advertisements"].empty?
  end
end