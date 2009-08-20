require File.dirname(__FILE__) + '/../test_helper'
class FeaturedPartnerControllerTest < ActionController::TestCase
  fixtures :featured_partners,:users
  def setup
    @controller = FeaturedPartnerController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["featured_partners"]
    assert_equal session[:return],{:controller => "featured_partner",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["featured_partners"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "featured_partner/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "featured_partner/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = FeaturedPartner.count
    post :edit,{:featured_partner => {:name => "Test #2"}},{:return => {:controller => "featured_partner",:action => "index"},:user => 1}
    assert_equal count+1,FeaturedPartner.count
    assert_response :redirect
    assert_redirected_to({:action => "view",:id => assigns["featured_partner"].id})
  end

  def test_005_add_invalid
    count = FeaturedPartner.count
    post :edit,{:featured_partner => {}},{:user => 1}
    assert_template "featured_partner/edit"
    assert_equal count,FeaturedPartner.count
  end

  def test_006_delete
    count = FeaturedPartner.count
    get :delete,{:id => 1},{:return => {:controller => "featured_partner",:action => "index"},:user => 1}
    assert_not_nil assigns["featured_partner"]
    assert_equal count,FeaturedPartner.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "featured_partner",:action => "index"},:user => 1}
    assert_equal count-1,FeaturedPartner.count
    assert_response :redirect
    assert_redirected_to({:controller => "featured_partner",:action => "index"})
  end

  def test_007_edit
    count = FeaturedPartner.count
    assert_equal "Name",FeaturedPartner.find(1).name
    post :edit,{:id => 1,:featured_partner => {:name => "Test"}},{:return => {:controller => "featured_partner",:action => "index"},:user => 1}
    assert_equal "Test",FeaturedPartner.find(1).name
    assert_response :redirect
    assert_redirected_to({:controller => "featured_partner",:action => "index"})
    assert_equal count,FeaturedPartner.count
  end

  def test_008_edit_invalid
    count = FeaturedPartner.count
    assert_equal "Name",FeaturedPartner.find(1).name
    post :edit,{:id => 1,:featured_partner => {:name => ""}},{:return => {:controller => "featured_partner",:action => "index"},:user => 1}
    assert_equal "Name",FeaturedPartner.find(1).name
    assert_response 200
    assert_template "featured_partner/edit"
    assert_equal count,FeaturedPartner.count
  end

  def test_009_view
    count = FeaturedPartner.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["featured_partner"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "featured_partner/view"
    assert_equal count,FeaturedPartner.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_nil assigns["featured_partner"]
      assert_template "main/404"
    end
  end
end