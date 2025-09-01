require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    post login_url, params: { 
      name: @user.name, 
      lastname: @user.lastname 
    }
    
    assert_redirected_to home_url
    assert_equal @user.id, session[:user_id]
    assert_equal 'Sesión iniciada correctamente', flash[:notice]
  end

  test "should not create session with invalid credentials" do
    post login_url, params: { 
      name: "Invalid", 
      lastname: "User" 
    }
    
    assert_response :success
    assert_nil session[:user_id]
    assert_equal 'Usuario no encontrado', flash[:alert]
  end

  test "should destroy session" do
    # First create a session
    post login_url, params: { 
      name: @user.name, 
      lastname: @user.lastname 
    }
    
    assert_equal @user.id, session[:user_id]
    
    # Then destroy it
    delete logout_url
    
    assert_redirected_to login_url
    assert_nil session[:user_id]
    assert_equal 'Sesión cerrada', flash[:notice]
  end

  test "should handle missing name parameter" do
    post login_url, params: { 
      lastname: @user.lastname 
    }
    
    assert_response :success
    assert_nil session[:user_id]
    assert_equal 'Usuario no encontrado', flash[:alert]
  end

  test "should handle missing lastname parameter" do
    post login_url, params: { 
      name: @user.name
    }
    
    assert_response :success
    assert_nil session[:user_id]
    assert_equal 'Usuario no encontrado', flash[:alert]
  end
end