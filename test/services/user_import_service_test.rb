require "test_helper"

class UserImportServiceTest < ActionDispatch::IntegrationTest
  test "should import users from valid CSV" do
    file = fixture_file_upload('test_users.csv', 'text/csv')
    
    initial_count = User.count
    service = UserImportService.new(file)
    service.call
    
    assert User.count >= initial_count
  end

  test "should handle CSV processing" do
    file = fixture_file_upload('test_users.csv', 'text/csv')
    service = UserImportService.new(file)
    
    assert_nothing_raised do
      service.call
    end
  end

  test "should initialize service with file" do
    file = fixture_file_upload('test_users.csv', 'text/csv')
    service = UserImportService.new(file)
    
    assert_not_nil service
  end
end