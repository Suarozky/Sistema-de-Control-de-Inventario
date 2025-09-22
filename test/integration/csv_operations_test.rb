require "test_helper"

class CsvOperationsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    post login_url, params: { 
      name: @admin.name, 
      lastname: @admin.lastname 
    }
  end

  test "complete CSV import/export flow for users" do
    # Export current users
    get export_users_url
    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.content_type
    
    # Import users
    file = fixture_file_upload('test_users.csv', 'text/csv')
    initial_count = User.count
    
    post import_users_url, params: { file: file }
    assert_redirected_to home_index_url
    assert User.count >= initial_count
  end

  test "complete CSV import/export flow for products" do
    # Export current products
    get export_products_url, params: { type: "product" }
    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.content_type
    
    # Import products
    file = fixture_file_upload('test_products.csv', 'text/csv')
    initial_count = Product.count
    
    post import_products_url, params: { file: file }
    assert_redirected_to products_url
  end

  test "CSV export for all data types" do
    # Test all export types
    %w[product brand model user transaction].each do |type|
      case type
      when "user"
        get export_users_url
      when "transaction"
        get export_transactions_url
      else
        get export_products_url, params: { type: type }
      end
      
      assert_response :success
      assert_equal "text/csv; charset=utf-8", response.content_type
    end
  end

  test "error handling for invalid export types" do
    get export_products_url, params: { type: "invalid" }
    assert_redirected_to products_url
    assert_match /Tipo de exportación no válido/, flash[:alert]
  end

  test "CSV import error handling" do
    # Test import without file
    post import_users_url
    assert_redirected_to users_url
    assert_equal "Por favor sube un archivo.", flash[:alert]
    
    post import_products_url
    assert_redirected_to products_url
    assert_equal "Por favor sube un archivo.", flash[:alert]
  end
end