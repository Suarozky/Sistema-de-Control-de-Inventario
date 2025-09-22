require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
  end

  test "authenticate_user! redirects when not logged in" do
    # Test through an existing protected route
    get users_url
    assert_response :redirect
  end

  test "authenticate_user! allows access when logged in" do
    # Login first
    post login_url, params: { 
      name: @user.name, 
      lastname: @user.lastname 
    }
    
    get users_url
    assert_response :success
  end

  test "current_user works through session" do
    post login_url, params: { 
      name: @user.name, 
      lastname: @user.lastname 
    }
    
    assert_equal @user.id, session[:user_id]
    
    get home_index_url
    assert_response :success
  end
end