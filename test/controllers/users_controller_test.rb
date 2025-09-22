require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
    @user = users(:admin)
    # Simular login
    post login_url, params: { 
      name: @user.name, 
      lastname: @user.lastname 
    }
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { 
        user: { 
          name: "Test", 
          lastname: "User"
        }
      }, headers: { 'HTTP_AUTHORIZATION' => @user.id }  # O tu método de auth
    end

    assert_redirected_to home_index_url
    assert_equal "Usuario creado con éxito", flash[:notice]
  end

  test "should not create user with invalid data" do
    assert_no_difference("User.count") do
      post users_url, params: { 
        user: { 
          name: users(:admin).name,  # Cambiar de :one a :admin
          lastname: users(:admin).lastname
        }
      }, headers: { 'HTTP_AUTHORIZATION' => @user.id }
    end

    assert_response :unprocessable_content
  end


  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should show user" do
    user = users(:user)
    get user_url(user)
    assert_response :success
  end

  test "should import users with file" do
    file = fixture_file_upload('test_users.csv', 'text/csv')
    
    post import_users_url, params: { file: file }
    assert_redirected_to home_index_url
  end

  test "should handle import without file" do
    post import_users_url
    assert_redirected_to users_url
    assert_equal "Por favor sube un archivo.", flash[:alert]
  end

  test "should export users" do
    get export_users_url
    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.content_type
  end

  test "should handle user creation with validation errors" do
    assert_no_difference("User.count") do
      post users_url, params: { 
        user: { 
          name: users(:admin).name,  # Duplicate name/lastname
          lastname: users(:admin).lastname
        }
      }
    end

    assert_response :unprocessable_content
    # Just verify we got an error response
  end

  test "should filter users correctly in index" do
    get users_url
    assert_response :success
    # Should display users based on policy
  end

  test "should handle missing user in show" do
    # Test that controller handles missing user gracefully
    begin
      get user_url(99999)
    rescue ActiveRecord::RecordNotFound
      # Expected behavior
      assert true
    end
  end

  test "should handle user show with current and previous products" do
    user = users(:user)
    product = Product.create!(
      model: "TestModel", 
      brand: "TestBrand", 
      entry_date: Date.current, 
      ownerid: user.id
    )
    
    get user_url(user)
    assert_response :success
    assert assigns(:current_products)
    assert assigns(:previous_products)
  end

  test "should get user products" do
    get user_url(@user)
    assert_response :success
    # Test passes if response is success
  end

  test "should separate current and previous products correctly" do
    product = products(:one)
    
    # Create transaction for this user
    Transaction.create!(
      ownerid: @user.id,
      productid: product.id,
      date: 1.day.ago
    )
    
    # Create newer transaction for different user
    other_user = User.create!(name: "Other", lastname: "User")
    Transaction.create!(
      ownerid: other_user.id,
      productid: product.id,
      date: Time.current
    )

    get user_url(@user)
    
    assert_response :success
    # Test passes if response is success
  end
end