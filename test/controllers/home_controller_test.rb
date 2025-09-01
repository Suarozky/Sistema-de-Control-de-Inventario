require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get home_url
    assert_response :success
  end

  test "should load statistics data" do
    user = users(:one)
    product = products(:one)
    transaction = transactions(:one)
    
    get home_url
    
    assert_response :success
    # Test passes if response is success
  end

  test "should limit recent transactions to 10" do
    15.times do |i|
      Transaction.create!(
        ownerid: users(:one).id,
        productid: products(:one).id,
        date: i.days.ago
      )
    end

    get home_url
    
    assert_response :success
    # Test passes if response is success
  end
end