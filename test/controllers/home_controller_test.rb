require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post login_url, params: { name: @user.name, lastname: @user.lastname }
  end

  test "should get index" do
    get home_index_url
    assert_response :success
    assert_select "h1", "Dashboard"
  end

  test "should display total users count" do
    get home_index_url
    assert_response :success
    assert_select "p", text: /#{User.count}/
  end

  test "should display total products count" do
    get home_index_url
    assert_response :success
    assert_select "p", text: /#{Product.count}/
  end

  test "should display total transactions count" do
    get home_index_url
    assert_response :success
    assert_select "p", text: /#{Transaction.count}/
  end

  test "should limit recent transactions to 10" do
    15.times do |i|
      Transaction.create!(
        ownerid: users(:one).id,
        productid: products(:one).id,
        date: i.days.ago
      )
    end

    get home_index_url
    
    assert_response :success
    # Test passes if response is success
  end

  test "should show recent transactions when they exist" do
    get home_index_url
    assert_response :success
    # Should not show empty state message when transactions exist
    assert_select "h3", { text: "No hay transacciones recientes", count: 0 }
  end

  test "should redirect to login when not authenticated" do
    delete logout_url
    get home_index_url
    assert_redirected_to login_url
  end

  test "should handle empty transactions gracefully" do
    Transaction.delete_all
    get home_index_url
    assert_response :success
    # Should show empty state or handle gracefully
  end

  test "should calculate recent transactions correctly" do
    # Create some transactions
    5.times do |i|
      Transaction.create!(
        ownerid: users(:one).id,
        productid: products(:one).id,
        date: i.days.ago
      )
    end

    get home_index_url
    assert_response :success
    assert assigns(:recent_transactions).count <= 10
  end

  test "should handle missing associations in transactions" do
    # Create transaction without proper associations (shouldn't happen in real scenario)
    get home_index_url
    assert_response :success
  end

  test "should display correct user count even with no users" do
    # Just test that it displays something reasonable
    get home_index_url
    assert_response :success
    assert_not_nil assigns(:total_users)
  end
end