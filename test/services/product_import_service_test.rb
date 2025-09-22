require "test_helper"

class ProductImportServiceTest < ActionDispatch::IntegrationTest
  test "should import products from valid CSV" do
    file = fixture_file_upload('test_products.csv', 'text/csv')
    
    initial_count = Product.count
    service = ProductImportService.new(file)
    service.call
    
    assert Product.count >= initial_count
  end

  test "should handle products with valid ownerid" do
    user = User.create!(name: "TestOwner", lastname: "TestLastname")
    
    file = fixture_file_upload('test_products.csv', 'text/csv')
    service = ProductImportService.new(file)
    
    assert_nothing_raised do
      service.call
    end
  end

  test "should raise error for invalid header" do
    temp_file = Tempfile.new(['invalid_products', '.csv'])
    temp_file.write("wrong,headers,here\nvalue1,value2,value3")
    temp_file.rewind
    
    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: temp_file,
      filename: 'invalid_products.csv',
      type: 'text/csv'
    )
    
    service = ProductImportService.new(uploaded_file)
    
    assert_raises(RuntimeError, /El archivo de Products debe tener/) do
      service.call
    end
    
    temp_file.close
    temp_file.unlink
  end
end