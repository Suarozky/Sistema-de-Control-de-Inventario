require "test_helper"

class SanitizationTest < ActiveSupport::TestCase
  test "export service sanitization methods" do
    service = ExportService.new("user")
    
    # Test various sanitization scenarios
    assert_equal "", service.send(:sanitize_field, nil)
    assert_equal "", service.send(:sanitize_field, "")
    assert_equal "test", service.send(:sanitize_field, "test")
    assert_equal "test", service.send(:sanitize_field, "  test  ")
    assert_equal "test value", service.send(:sanitize_field, "test\nvalue")
    assert_equal "test value", service.send(:sanitize_field, "test\tvalue")
    assert_equal "test value", service.send(:sanitize_field, "test\rvalue")
  end

  test "export service header generation" do
    user_service = ExportService.new("user")
    assert_equal ["name", "lastname"], user_service.send(:headers)
    
    brand_service = ExportService.new("brand")
    assert_equal ["name"], brand_service.send(:headers)
    
    model_service = ExportService.new("model")
    assert_equal ["name"], model_service.send(:headers)
    
    product_service = ExportService.new("product")
    assert_equal ["brand", "model", "entry_date", "ownerid"], product_service.send(:headers)
    
    transaction_service = ExportService.new("transaction")
    assert_equal ["ownerid", "productid", "date"], transaction_service.send(:headers)
  end

  test "export service model mapping" do
    service = ExportService.new("user")
    assert_equal User, service.instance_variable_get(:@klass)
    
    service = ExportService.new("brand")
    assert_equal Brand, service.instance_variable_get(:@klass)
    
    service = ExportService.new("model")
    assert_equal Model, service.instance_variable_get(:@klass)
    
    service = ExportService.new("product")
    assert_equal Product, service.instance_variable_get(:@klass)
    
    service = ExportService.new("transaction")
    assert_equal Transaction, service.instance_variable_get(:@klass)
  end
end