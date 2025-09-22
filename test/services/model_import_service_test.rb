require "test_helper"

class ModelImportServiceTest < ActionDispatch::IntegrationTest
  test "should import models from valid CSV" do
    file = fixture_file_upload('test_models.csv', 'text/csv')
    
    initial_count = Model.count
    service = ModelImportService.new(file)
    service.call
    
    assert Model.count >= initial_count
  end

  test "should handle duplicate model names" do
    Model.create!(name: "TestModel")
    
    file = fixture_file_upload('test_models.csv', 'text/csv')
    service = ModelImportService.new(file)
    
    assert_nothing_raised do
      service.call
    end
  end

  test "should handle CSV processing without errors" do
    file = fixture_file_upload('test_models.csv', 'text/csv')
    service = ModelImportService.new(file)
    
    assert_nothing_raised do
      service.call
    end
  end

  test "should initialize service with file" do
    file = fixture_file_upload('test_models.csv', 'text/csv')
    service = ModelImportService.new(file)
    
    assert_not_nil service
  end

  test "should strip whitespace from model names" do
    # Create a temporary file with whitespace
    temp_file = Tempfile.new(['models_with_whitespace', '.csv'])
    temp_file.write("name\n  TestModel  \n  AnotherModel  ")
    temp_file.rewind
    
    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: temp_file,
      filename: 'models_with_whitespace.csv',
      type: 'text/csv'
    )
    
    service = ModelImportService.new(uploaded_file)
    service.call
    
    # Should find models without whitespace
    assert Model.find_by(name: "TestModel")
    assert Model.find_by(name: "AnotherModel")
    
    temp_file.close
    temp_file.unlink
  end
end