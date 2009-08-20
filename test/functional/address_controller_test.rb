require File.dirname(__FILE__) + '/../test_helper'
class AddressControllerTest < ActionController::TestCase
  fixtures :addresses,:users
  def setup
    @controller = AddressController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["addresses"]
    assert_equal session[:return],{:controller => "address",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["addresses"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "address/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "address/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = Address.count
    post :edit,{:address => {:street => "555 S Logan St",:city => "Denver",:state => "CO",:postal_code => 80209}},{:return => {:controller => "address",:action => "index"},:user => 1}
    assert_equal Address.count,count+1
    assert_response :redirect
    return_url = {:controller => "address",:action => "view",:id => assigns["address"].id}
    assert_redirected_to return_url
  end

  def test_005_add_invalid
    count = Address.count
    post :edit,{:address => {}},{:user => 1}
    assert_template "address/edit"
    assert_equal Address.count,count
  end

  def test_006_delete
    count = Address.count
    get :delete,{:id => 1},{:return => {:controller => "address",:action => "index"},:user => 1}
    assert_not_nil assigns["address"]
    assert_equal Address.count,count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "address",:action => "index"},:user => 1}
    assert_equal Address.count,count-1
    assert_response :redirect
    hash = {:controller => "address",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = Address.count
    assert_equal Address.find(1).street,"1608 S Lafayette St"
    post :edit,{:id => 1,:address => {:street => "2200 Market St",:city => "Denver",:state => "CO"}},{:return => {:controller => "address",:action => "index"},:user => 1}
    assert_equal Address.find(1).street,"2200 Market St"
    hash = {:controller => "address",:action => "index"}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal Address.count,count
  end

  def test_008_edit_invalid
    count = Address.count
    assert_equal Address.find(1).street,"1608 S Lafayette St"
    post :edit,{:id => 1,:address => {:city => "",:state => ""}},{:return => {:controller => "address",:action => "index"},:user => 1}
    assert_equal Address.find(1).street,"1608 S Lafayette St"
    assert_response 200
    assert_template "address/edit"
    assert_equal Address.count,count
  end

  def test_009_view
    count = Address.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["address"]
    # assert_not_nil session[:return]
    assert_response 200
    assert_template "address/view"
    assert_equal Address.count,count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end
end