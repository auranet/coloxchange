require File.dirname(__FILE__) + '/../test_helper'
class CommissionPaymentControllerTest < ActionController::TestCase
  fixtures :commission_payments,:term_lengths,:users
  def setup
    @controller = CommissionPaymentController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["commission_payments"]
    assert_equal session[:return],{:controller => "commission_payment",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["commission_payments"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "commission_payment/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "commission_payment/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = CommissionPayment.count
    post :edit,{:commission_payment => {:amount => 109.99,:salesperson_id => 1,:date => 2.months.from_now.to_date,:order_id => 1}},{:return => {:controller => "commission_payment",:action => "index"},:user => 1}
    assert_equal count+1,CommissionPayment.count
    assert_response :redirect
    return_url = {:controller => "order",:action => "view",:id => 1}
    assert_redirected_to return_url
    post :edit,{:commission_payment => {:amount => 149.99,:salesperson_id => 2,:date => 1.year.from_now.to_date,:advertisement_order_id => 1}},{:return => {:controller => "commission_payment",:action => "index"},:user => 1}
    assert_equal count+1,CommissionPayment.count
    assert_response :redirect
    return_url = {:controller => "advertisement",:action => "view",:id => 1}
    assert_redirected_to return_url
  end

  def test_005_add_invalid
    count = CommissionPayment.count
    post :edit,{:commission_payment => {}},{:user => 1}
    assert_template "commission_payment/edit"
    assert_equal count,CommissionPayment.count
  end

  def test_006_delete
    count = CommissionPayment.count
    get :delete,{:id => 1},{:return => {:controller => "commission_payment",:action => "index"},:user => 1}
    assert_not_nil assigns["commission_payment"]
    assert_equal count,CommissionPayment.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "commission_payment",:action => "index"},:user => 1}
    assert_equal count-1,CommissionPayment.count
    assert_response :redirect
    hash = {:controller => "commission_payment",:action => "index"}
    assert_redirected_to hash
  end

  def test_007_edit
    count = CommissionPayment.count
    assert_equal "A $49.99 payment to Elizabeth Sasser on #{1.month.from_now.to_date.pretty_short}",CommissionPayment.find(1).name
    post :edit,{:id => 1,:commission_payment => {:amount => 53.28,:salesperson_id => 1,:date => 2.months.from_now.to_date,:order_id => 1}},{:return => {:controller => "commission_payment",:action => "index"},:user => 1}
    assert_equal "A $53.28 payment to Flip Sasser on #{2.months.from_now.to_date.pretty_short}",CommissionPayment.find(1).name
    hash = {:controller => "order",:action => "view",:id => 1}
    assert_response :redirect
    assert_redirected_to hash
    assert_equal count,CommissionPayment.count
  end

  def test_008_edit_invalid
    count = CommissionPayment.count
    assert_equal "A $49.99 payment to Elizabeth Sasser on #{1.month.from_now.to_date.pretty_short}",CommissionPayment.find(1).name
    post :edit,{:id => 1,:commission_payment => {:amount => nil,:salesperson_id => 1,:date => 2.months.from_now.to_date,:order_id => 1}},{:return => {:controller => "commission_payment",:action => "index"},:user => 1}
    assert_equal "A $49.99 payment to Elizabeth Sasser on #{1.month.from_now.to_date.pretty_short}",CommissionPayment.find(1).name
    assert_response 200
    assert_template "commission_payment/edit"
    assert_equal count,CommissionPayment.count
  end

  def test_009_view
    count = CommissionPayment.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["commission_payment"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "commission_payment/view"
    assert_equal count,CommissionPayment.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_template "main/404"
    end
  end

  def test_011_related_records
    get :edit,{:advertisement_order_id => 1},{:user => 1}
    assert_response 200
    get :edit,{:order_id => 1},{:user => 1}
    assert_response 200
    get :edit,{:advertisement_order_id => 1000},{:user => 1}
    assert_response 404
    get :edit,{:order_id => 1000},{:user => 1}
    assert_response 404
  end
end