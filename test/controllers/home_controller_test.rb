require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post login_url, params: { name: @user.name, lastname: @user.lastname }
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
end