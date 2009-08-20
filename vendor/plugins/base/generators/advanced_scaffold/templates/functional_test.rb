require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../test_helper'
class <%= class_name.pluralize %>ControllerTest < ActionController::TestCase
  fixtures :<%= file_name.pluralize %>,:users
  def setup
    @controller = <%= class_name.pluralize %>Controller.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_001_index
    get :index,{},{:user => 1}
    assert_response 200
    assert_not_nil assigns["user"]
    assert_not_nil assigns["<%= file_name.pluralize %>"]
    assert_equal session[:return],{:controller => "<%= file_name %>",:action => "index"}
  end

  def test_002_index_no_basic_auth
    get :index
    assert_response 401
    assert_template "main/login"
    assert_nil assigns["user"]
    assert_nil assigns["<%= file_name.pluralize %>"]
  end

  # def test_003_no_admin_auth
  #   for method in [:edit,:index]
  #     get method,{},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{},{:user => 1}
  #     assert_response 200
  #     assert_template "<%= file_name %>/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  #   for method in [:delete,:edit,:view]
  #     get method,{:id => 1},{:user => 2}
  #     assert_response 401
  #     assert_template "main/login"
  #     get method,{:id => 1},{:user => 1}
  #     assert_response 200
  #     assert_template "<%= file_name %>/#{method}"
  #     assert_not_nil assigns["user"]
  #   end
  # end

  def test_004_add
    count = <%= class_name %>.count
    post :edit,{:<%= file_name %> => {:name => "Test #2"}},{:return => {:controller => "<%= file_name %>",:action => "index"},:user => 1}
    assert_equal count+1,<%= class_name %>.count
    assert_response :redirect
    assert_redirected_to({:action => "show",:id => assigns["<%= file_name %>"].id})
  end

  def test_005_add_invalid
    count = <%= class_name %>.count
    post :edit,{:<%= file_name %> => {}},{:user => 1}
    assert_template "<%= file_name %>/edit"
    assert_equal count,<%= class_name %>.count
  end

  def test_006_delete
    count = <%= class_name %>.count
    get :delete,{:id => 1},{:return => {:controller => "<%= file_name %>",:action => "index"},:user => 1}
    assert_not_nil assigns["<%= file_name %>"]
    assert_equal count,<%= class_name %>.count
    get :delete,{:id => 1,:confirm => "yes"},{:return => {:controller => "<%= file_name %>",:action => "index"},:user => 1}
    assert_equal count-1,<%= class_name %>.count
    assert_response :redirect
    assert_redirected_to({:controller => "<%= file_name %>",:action => "index"})
  end

  def test_007_edit
    count = <%= class_name %>.count
    assert_equal "Name",<%= class_name %>.find(1).name
    post :edit,{:id => 1,:<%= file_name %> => {:name => "Test"}},{:return => {:controller => "<%= file_name %>",:action => "index"},:user => 1}
    assert_equal "Test",<%= class_name %>.find(1).name
    assert_response :redirect
    assert_redirected_to({:controller => "<%= file_name %>",:action => "index"})
    assert_equal count,<%= class_name %>.count
  end

  def test_008_edit_invalid
    count = <%= class_name %>.count
    assert_equal "Name",<%= class_name %>.find(1).name
    post :edit,{:id => 1,:<%= file_name %> => {:name => ""}},{:return => {:controller => "<%= file_name %>",:action => "index"},:user => 1}
    assert_equal "Name",<%= class_name %>.find(1).name
    assert_response 200
    assert_template "<%= file_name %>/edit"
    assert_equal count,<%= class_name %>.count
  end

  def test_009_view
    count = <%= class_name %>.count
    get :view,{:id => 1},{:user => 1}
    assert_not_nil assigns["<%= file_name %>"]
    assert_not_nil session[:return]
    assert_response 200
    assert_template "<%= file_name %>/view"
    assert_equal count,<%= class_name %>.count # Make sure we're not creating records here... I mean, why would we? But just to be sure.
  end

  def test_010_deny
    for method in [:delete,:edit,:view]
      get method,{:id => 1000},{:user => 1}
      assert_response 404
      assert_nil assigns["<%= file_name %>"]
      assert_template "main/404"
    end
  end<% if actions.include?("filter") %>

  def test_011_filtering
    get :index,{:filter => {"name" => "Test <%= class_name %>"}},{:user => 1}
    assert_response 200
    assert_equal 1,assigns["<%= file_name %>"].size
    get :index,{:filter => {"name" => "Test <%= class_name %>",:status => [0]}},{:user => 1}
    assert_response 200
    assert_equal 1,assigns["<%= file_name %>"].size
    get :index,{:filter => {"name" => "Test <%= class_name %>",:status => [1]}},{:user => 1}
    assert_response 200
    assert assigns["<%= file_name %>"].empty?
  end<% end %><% if actions.include?("autocomplete") %>

  def test_012_autocomplete
    get :autocomplete,{:value => "Test <%= class_name %>"},{:user => 1}
    assert_response 200
    assert_template "<%= file_name %>/autocomplete"
    assert_not_nil assigns["<%= file_name.pluralize %>"]
    assert_equal 1,assigns["<%= file_name.pluralize %>"].size
    get :autocomplete,{:value => "Foo Bar"},{:user => 1}
    assert_response 200
    assert_template "<%= file_name %>/autocomplete"
    assert_not_nil assigns["<%= file_name.pluralize %>"]
    assert assigns["<%= file_name.pluralize %>"].empty?
    get :autocomplete,{},{:user => 1}
    assert_response 200
    assert_template "<%= file_name %>/autocomplete"
    assert_not_nil assigns["<%= file_name.pluralize %>"]
    assert assigns["<%= file_name.pluralize %>"].empty?
  end<% end %>
end



# 
# require File.dirname(__FILE__) + '/../test_helper'
# 
# class FoosControllerTest < ActionController::TestCase
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert_not_nil assigns(:foos)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
# 
#   def test_should_create_foo
#     assert_difference('Foo.count') do
#       post :create, :foo => { }
#     end
# 
#     assert_redirected_to foo_path(assigns(:foo))
#   end
# 
#   def test_should_show_foo
#     get :show, :id => foos(:one).id
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => foos(:one).id
#     assert_response :success
#   end
# 
#   def test_should_update_foo
#     put :update, :id => foos(:one).id, :foo => { }
#     assert_redirected_to foo_path(assigns(:foo))
#   end
# 
#   def test_should_destroy_foo
#     assert_difference('Foo.count', -1) do
#       delete :destroy, :id => foos(:one).id
#     end
# 
#     assert_redirected_to foos_path
#   end
# end
