require "test_helper"

class BrandImportServiceTest < ActionDispatch::IntegrationTest
  test "should import brands from valid CSV" do
    file = fixture_file_upload('test_brands.csv', 'text/csv')
    
    initial_count = Brand.count
    service = BrandImportService.new(file)
    service.call
    
    assert Brand.count > initial_count
  end

  test "should handle duplicate brand names" do
    Brand.create!(name: "TestBrand")
    
    file = fixture_file_upload('test_brands.csv', 'text/csv')
    service = BrandImportService.new(file)
    
    assert_nothing_raised do
      service.call
    end
  end

  test "should raise error for invalid header" do
    # Create a temporary file with wrong headers
    temp_file = Tempfile.new(['invalid_brands', '.csv'])
    temp_file.write("wrong_header\nvalue1")
    temp_file.rewind
    
    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: temp_file,
      filename: 'invalid_brands.csv',
      type: 'text/csv'
    )
    
    service = BrandImportService.new(uploaded_file)
    
    assert_raises(RuntimeError, /El archivo de Brands debe tener solo la columna/) do
      service.call
    end
    
    temp_file.close
    temp_file.unlink
  end
end