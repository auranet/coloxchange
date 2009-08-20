require File.expand_path(File.dirname(__FILE__) + '/../../../base/test/test_helper')
Test::Unit::TestCase.fixture_path = File.expand_path(File.dirname(__FILE__) + "/../fixtures")

class AdminControllerTest < ActionController::TestCase
  fixtures :admin_roles,:admin_permissions,:users
  def setup
    @controller = AdminController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    User.find(1).admin_roles << AdminRole.find_by_name("Admin")
    User.find(2).admin_roles << AdminRole.find_by_name("Blogger")
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    get :index,{},{:user => 2}
    assert_response 200
    assert_not_nil assigns["user"]
  end

  def test_002_index_no_auth
    get :index
    assert_response 401
    assert_nil assigns["user"]
  end

  def test_003_index_small_permissions
    get :index,{},{:user => 2}
    assert_response 200
    assert_not_nil assigns["models"]
  end

  def test_004_all_models
    User.find(1).admin_roles << AdminRole.find_by_name("Admin")
    User.find(2).admin_roles << AdminRole.find_by_name("Blogger")
    for model in Admin.models
      get :browse,{:model => model.tableize},{:user => 1}
      assert_response 200
      assert_not_nil assigns["instances"]
    end
  end

  def test_005_private_models_omnipotent
    User.find(1).admin_roles << AdminRole.find_by_name("Admin")
    for model in Admin.models
      get :browse,{:model => model.tableize},{:user => 1}
      assert_response 200
      assert_not_nil assigns["instances"]
    end
  end

  def test_005_private_models_blogger
    User.find(2).admin_roles << AdminRole.find_by_name("Blogger")
    for model in Admin.models
      get :browse,{:model => model.tableize},{:user => 2}
      assert_response 
      assert_not_nil assigns["instances"]
    end
  end
end