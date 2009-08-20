require File.dirname(__FILE__) + '/../test_helper'
class UserControllerTest < ActionController::TestCase
  fixtures :users
  def setup
    @controller = UserController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["users"]
    assert_equal session[:return],{:controller => "user",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["users"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "user/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "user/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = User.count
    post :edit,{:edit_user => {:first_name => "Flip",:last_name => "Testaccount",:email => "flip.sasser@foo.com",:password => "password19"}},{:return => {:controller => "user",:action => "index"},:user => 1}
    assert_equal count+1,User.count
    assert_response :redirect
    return_url = {:action => "view",:id => assigns["edit_user"].id}
    assert_redirected_to return_url
  end

  def test_005_add_invalid
    count = User.count
    post :edit,{:edit_user => {:first_name => "Steve",:last_name => "Brokentestaccount",:email => "flip.sasser@gmail.com",:password => "password19"}},{:user => 1}
    assert_template "user/edit"
    assert_equal count,User.count
  end

  def test_006_delete
    count = User.count
    get :delete,{:id => 1},{:return => {:controller => "user",:action => "index"},:user => 1}
    assert_not_nil assigns["edit_user"]
    assert_equal count,User.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "user",:action => "index"},:user => 1}
    assert_equal count,User.count
    assert_response :redirect
    hash = {:controller => "user",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = User.count
    assert_equal "Flip Sasser",User.find(1).name
    post :edit,{:id => 1,:edit_user => {:first_name => "Dwayne \"The Rock\"",:last_name => "Johnson"}},{:return => {:controller => "user",:action => "index"},:user => 1}
    assert_equal "Dwayne \"The Rock\" Johnson",User.find(1).name
    hash = {:controller => "user",:action => "index"}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal count,User.count
  end

  def test_008_edit_invalid
    count = User.count
    assert_equal "Flip Sasser",User.find(1).name
    post :edit,{:id => 1,:edit_user => {:first_name => ""}},{:return => {:controller => "user",:action => "index"},:user => 1}
    assert_equal "Flip Sasser",User.find(1).name
    assert_response 200
    assert_template "user/edit"
    assert_equal count,User.count
  end

  def test_009_view
    count = User.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["edit_user"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "user/view"
    assert_equal count,User.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end

  # def test_011_filtering
  #   get :index,{:filter => {"name" => "20 Odd"}},{:user => 1}
  #   assert_response 200
  #   assert_equal 1,assigns["users"].size
  #   get :index,{:filter => {"name" => "Sasser Inte"}},{:user => 1}
  #   assert_response 200
  #   assert_equal 1,assigns["companies"].size
  #   get :index,{:filter => {"name" => "Foo McBar"}},{:user => 1}
  #   assert_response 200
  #   assert assigns["companies"].empty?
  # end

  def test_012_autocomplete
    get :autocomplete,{:value => "Flip Sasser"},{:user => 1}
    assert_response 200
    assert_template "user/autocomplete"
    assert_not_nil assigns["users"]
    assert_equal 1,assigns["users"].size
    get :autocomplete,{:value => "Elizabeth Mulligan"},{:user => 1}
    assert_response 200
    assert_template "user/autocomplete"
    assert_not_nil assigns["users"]
    assert assigns["users"].empty?
    get :autocomplete,{},{:user => 1}
    assert_response 200
    assert_template "user/autocomplete"
    assert_not_nil assigns["users"]
    assert assigns["users"].empty?
  end
end