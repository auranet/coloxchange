require File.dirname(__FILE__) + '/../test_helper'
class DataCenterTest < ActiveSupport::TestCase
  fixtures :data_centers

  def setup
    @controller = DataCenterController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @user = User.find(:first)
  end

  def test_001_index_no_auth
    @user = nil
    get :index
    assert_response 401
  end

  def test_001_index_with_auth
    get :index
    assert_response 200
  end
end
