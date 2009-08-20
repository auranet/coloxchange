require File.dirname(__FILE__) + '/../test_helper'
class ContactControllerTest < ActionController::TestCase
  fixtures :users
  def setup
    @controller = ContactController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["contacts"]
    assert_equal session[:return],{:controller => "contact",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["contacts"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "contact/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 3},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 3},{:user => 1}
  #     assert_response 200
  #     assert_template "contact/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = Contact.count
    post :edit,{:contact => {:first_name => "Test",:last_name => "Contact"}},{:return => {:controller => "contact",:action => "index"},:user => 1}
    assert_equal count+1,Contact.count
    assert_response :redirect
    return_url = {:action => "view",:id => assigns["contact"].id}
    assert_redirected_to return_url
  end

  def test_005_add_invalid
    count = Contact.count
    post :edit,{:contact => {}},{:user => 1}
    assert_template "contact/edit"
    assert_equal count,Contact.count
  end

  def test_006_delete
    count = Contact.count
    get :delete,{:id => 3},{:return => {:controller => "contact",:action => "index"},:user => 1}
    assert_not_nil assigns["contact"]
    assert_equal count,Contact.count
    get :delete,{:id => 3,:confirm => "yes"},{:return => {:controller => "contact",:action => "index"},:user => 1}
    assert_equal count-1,Contact.count
    assert_response :redirect
    hash = {:controller => "contact",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = Contact.count
    assert_equal Contact.find(3).name,"Contact Name"
    post :edit,{:id => 3,:contact => {:first_name => "Test",:last_name => "Contact"}},{:return => {:controller => "contact",:action => "index"},:user => 1}
    assert_equal Contact.find(3).name,"Test Contact"
    hash = {:controller => "contact",:action => "index"}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal count,Contact.count
  end

  def test_008_edit_invalid
    count = Contact.count
    assert_equal "Contact Name",Contact.find(3).name
    post :edit,{:id => 3,:contact => {:first_name => "",:last_name => ""}},{:return => {:controller => "contact",:action => "index"},:user => 1}
    assert_equal "Contact Name",Contact.find(3).name
    assert_response 200
    assert_template "contact/edit"
    assert_equal count,Contact.count
  end

  def test_009_view
    count = Contact.count
    get :view,{:id => 3},{:user => 1}
    assert_not_nil assigns["contact"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "contact/view"
    assert_equal count,Contact.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end
end