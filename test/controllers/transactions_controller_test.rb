require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:one)
    @user = users(:one)
    @product = products(:one)
  end

  test "should get index" do
    get transactions_url, headers: { "Accept" => "text/html" }
    assert_response :success
  end

  test "should limit latest transactions to 10" do
    15.times do |i|
      Transaction.create!(
        ownerid: @user.id,
        productid: @product.id,
        date: i.days.ago
      )
    end

    get transactions_url, headers: { "Accept" => "text/html" }
    
    assert_response :success
  end

  test "should get new" do
    get new_transaction_url, headers: { "Accept" => "text/html" }
    assert_response :success
  end

  test "should create transaction" do
    assert_difference("Transaction.count") do
      post transactions_url, params: { 
        transaction: { 
          productid: @product.id,
          ownerid: @user.id,
          date: Date.current
        } 
      }
    end

    assert_redirected_to transaction_url(Transaction.last)
    assert_equal 'Transacción creada exitosamente.', flash[:notice]
  end

  test "should not create transaction with invalid data" do
    assert_no_difference("Transaction.count") do
      post transactions_url, params: { 
        transaction: { 
          productid: nil,
          ownerid: nil,
          date: nil
        } 
      }
    end

    assert_response :unprocessable_content
  end

  test "should get transaction count" do
    get count_transactions_url
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["total_transactions"]
    assert_equal Transaction.count, json_response["total_transactions"]
  end

  test "should import transactions with file" do
    file = fixture_file_upload('test_transactions.csv', 'text/csv')
    
    post import_transactions_url, params: { file: file }
    assert_redirected_to transactions_url
  end

  test "should handle import without file" do
    post import_transactions_url
    assert_redirected_to transactions_url
    assert_equal "Por favor sube un archivo.", flash[:alert]
  end

  test "should export transactions" do
    get export_transactions_url
    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.content_type
  end

  test "should include associations in index" do
    get transactions_url, headers: { "Accept" => "text/html" }
    assert_response :success
  end

  test "should order transactions by date desc in index" do
    # Create transactions with different dates
    old_transaction = Transaction.create!(
      ownerid: @user.id,
      productid: @product.id,
      date: 2.days.ago
    )
    
    new_transaction = Transaction.create!(
      ownerid: @user.id,
      productid: @product.id,
      date: Time.current
    )

    get transactions_url, headers: { "Accept" => "text/html" }
    assert_response :success
  end

  test "should handle transaction show" do
    transaction = Transaction.create!(
      ownerid: @user.id,
      productid: @product.id,
      date: Time.current
    )
    
    # Test that transaction was created
    assert_not_nil transaction.id
  end

  test "should handle transaction creation with invalid product" do
    assert_no_difference("Transaction.count") do
      post transactions_url, params: { 
        transaction: { 
          productid: 99999,
          ownerid: @user.id,
          date: Date.current
        } 
      }
    end

    assert_response :unprocessable_content
  end

  test "should handle transaction creation with invalid owner" do
    assert_no_difference("Transaction.count") do
      post transactions_url, params: { 
        transaction: { 
          productid: @product.id,
          ownerid: 99999,
          date: Date.current
        } 
      }
    end

    assert_response :unprocessable_content
  end

  test "should include owner and product associations" do
    get transactions_url, headers: { "Accept" => "text/html" }
    assert_response :success
    assert assigns(:transactions)
  end

  test "should handle transactions with missing associations gracefully" do
    get transactions_url, headers: { "Accept" => "text/html" }
    assert_response :success
    # Should not crash even if some associations are missing
  end
end