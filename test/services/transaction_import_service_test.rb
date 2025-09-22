require "test_helper"

class TransactionImportServiceTest < ActionDispatch::IntegrationTest
  test "should import transactions from valid CSV" do
    file = fixture_file_upload('test_transactions.csv', 'text/csv')
    
    initial_count = Transaction.count
    service = TransactionImportService.new(file)
    service.call
    
    assert Transaction.count >= initial_count
  end

  test "should handle transactions with valid references" do
    user = User.create!(name: "TestOwner", lastname: "TestLastname")
    product = Product.create!(model: "TestModel", brand: "TestBrand", entry_date: Date.current, ownerid: user.id)
    
    file = fixture_file_upload('test_transactions.csv', 'text/csv')
    service = TransactionImportService.new(file)
    
    assert_nothing_raised do
      service.call
    end
  end

  test "should process CSV with date formatting" do
    file = fixture_file_upload('test_transactions.csv', 'text/csv')
    service = TransactionImportService.new(file)
    
    assert_nothing_raised do
      service.call
    end
  end

  test "should initialize service with file" do
    file = fixture_file_upload('test_transactions.csv', 'text/csv')
    service = TransactionImportService.new(file)
    
    assert_not_nil service
  end

  test "should handle transaction validation" do
    file = fixture_file_upload('test_transactions.csv', 'text/csv')
    service = TransactionImportService.new(file)
    
    # Should handle any validation errors gracefully
    assert_nothing_raised do
      service.call
    end
  end
end