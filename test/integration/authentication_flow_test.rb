require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test "complete authentication flow" do
    user = users(:user)
    
    # Visit protected page when not logged in
    get users_url
    assert_redirected_to login_url
    
    # Log in with valid credentials
    post login_url, params: { 
      name: user.name, 
      lastname: user.lastname 
    }
    assert_redirected_to home_index_url
    assert_equal user.id, session[:user_id]
    
    # Access protected page when logged in
    get users_url
    assert_response :success
    
    # Log out
    delete logout_url
    assert_redirected_to login_url
    assert_nil session[:user_id]
    
    # Try to access protected page after logout
    get users_url
    assert_redirected_to login_url
  end

  test "login with invalid credentials" do
    post login_url, params: { 
      name: "invalid", 
      lastname: "user" 
    }
    assert_redirected_to login_path
    assert_nil session[:user_id]
    assert_equal 'Usuario no encontrado', flash[:alert]
  end

  test "helper methods work correctly" do
    user = users(:user)
    
    # Not logged in
    get home_index_url
    assert_redirected_to login_url
    
    # Log in
    post login_url, params: { 
      name: user.name, 
      lastname: user.lastname 
    }
    
    # Access page that uses helper methods
    get home_index_url
    assert_response :success
  end

  test "current_user persistence across requests" do
    user = users(:user)
    
    post login_url, params: { 
      name: user.name, 
      lastname: user.lastname 
    }
    
    # Make multiple requests to ensure current_user persists
    get home_index_url
    assert_response :success
    
    get users_url
    assert_response :success
    
    get products_url
    assert_response :success
  end
end