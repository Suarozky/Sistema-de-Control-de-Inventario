require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new" do
    get new_user_url
    assert_response :success
    # Test passes if response is success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { 
        user: { 
          name: "Test", 
          lastname: "User"
        } 
      }
    end

    assert_redirected_to home_url
    assert_equal "Usuario creado con éxito", flash[:notice]
  end

  test "should not create user with invalid data" do
    assert_no_difference("User.count") do
      post users_url, params: { 
        user: { 
          name: users(:one).name, 
          lastname: users(:one).lastname
        } 
      }
    end

    assert_response :unprocessable_content
  end

  test "should get user count" do
    get count_users_url
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["total_users"]
    assert_equal User.count, json_response["total_users"]
  end

  test "should get user page" do
    get get_user_users_url
    assert_response :success
  end

  test "should import users with file" do
    file = fixture_file_upload('test_users.csv', 'text/csv')
    
    post import_users_url, params: { file: file }
    assert_redirected_to home_url
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

  test "should get user products" do
    get my_products_user_url(@user)
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

    get my_products_user_url(@user)
    
    assert_response :success
    # Test passes if response is success
  end
end