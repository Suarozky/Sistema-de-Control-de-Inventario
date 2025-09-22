require "test_helper"

class ExportServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:user)
    @product = products(:one)
  end

  test "should export users to CSV" do
    service = ExportService.new("user")
    csv_data = service.call
    
    assert_includes csv_data, "name;lastname"
    assert_includes csv_data, "#{@user.name};#{@user.lastname}"
  end

  test "should export brands to CSV" do
    brand = Brand.create!(name: "Test Brand")
    service = ExportService.new("brand")
    csv_data = service.call
    
    assert_includes csv_data, "name"
    assert_includes csv_data, "Test Brand"
  end

  test "should export models to CSV" do
    model = Model.create!(name: "Test Model")
    service = ExportService.new("model")
    csv_data = service.call
    
    assert_includes csv_data, "name"
    assert_includes csv_data, "Test Model"
  end

  test "should export products to CSV" do
    service = ExportService.new("product")
    csv_data = service.call
    
    assert_includes csv_data, "brand;model;entry_date;ownerid"
    assert_includes csv_data, @product.brand
    assert_includes csv_data, @product.model
  end

  test "should export transactions to CSV" do
    transaction = Transaction.create!(
      ownerid: @user.id,
      productid: @product.id,
      date: Time.current
    )
    
    service = ExportService.new("transaction")
    csv_data = service.call
    
    assert_includes csv_data, "ownerid;productid;date"
    assert_includes csv_data, @user.id.to_s
    assert_includes csv_data, @product.id.to_s
  end

  test "should raise error for unknown type" do
    assert_raises(RuntimeError, "Tipo desconocido: unknown") do
      ExportService.new("unknown")
    end
  end

  test "should sanitize fields with special characters" do
    user = User.create!(name: "Test\nName", lastname: "Test\tLastname")
    service = ExportService.new("user")
    csv_data = service.call
    
    assert_includes csv_data, "Test Name;Test Lastname"
    # CSV uses \r\n as line endings, so we check that tabs and newlines in data are replaced
    lines = csv_data.split("\r\n")
    user_line = lines.find { |line| line.include?("Test Name") }
    assert_not_includes user_line, "\n"
    assert_not_includes user_line, "\t"
  end

  test "should handle nil fields" do
    service = ExportService.new("user")
    sanitized = service.send(:sanitize_field, nil)
    assert_equal "", sanitized
  end

  test "should strip whitespace from fields" do
    service = ExportService.new("user")
    sanitized = service.send(:sanitize_field, "  test  ")
    assert_equal "test", sanitized
  end

  test "should convert symbols to string when initializing" do
    service = ExportService.new(:user)
    csv_data = service.call
    assert_includes csv_data, "name;lastname"
  end

  test "should handle uppercase type" do
    service = ExportService.new("USER")
    csv_data = service.call
    assert_includes csv_data, "name;lastname"
  end

  test "should generate proper CSV format" do
    service = ExportService.new("brand")
    csv_data = service.call
    
    lines = csv_data.split("\r\n")
    assert_equal "name", lines.first
  end

  test "should handle empty records" do
    # Test with a type that doesn't have foreign key constraints
    Brand.delete_all
    service = ExportService.new("brand")
    csv_data = service.call
    
    # Should only have headers
    lines = csv_data.split("\r\n").reject(&:empty?)
    assert_equal 1, lines.count
    assert_equal "name", lines.first
  end

  test "should format dates correctly" do
    product = Product.create!(
      model: "TestModel", 
      brand: "TestBrand", 
      entry_date: Date.new(2023, 1, 15),
      ownerid: users(:user).id
    )
    
    service = ExportService.new("product")
    csv_data = service.call
    
    assert_includes csv_data, "2023-01-15"
  end

  test "should handle nil dates" do
    # Test with a record that might have nil date
    service = ExportService.new("product")
    sanitized_date = service.send(:row_for, Product.new)
    
    # Should handle nil gracefully
    assert_not_nil sanitized_date
  end
end