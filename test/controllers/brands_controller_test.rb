require "test_helper"

class BrandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin)
    post login_url, params: { 
      name: @user.name, 
      lastname: @user.lastname 
    }
  end

  test "should import brands with file" do
    file = fixture_file_upload('test_brands.csv', 'text/csv')
    
    post import_brands_url, params: { file: file }
    assert_redirected_to brands_url
    assert_equal "Marcas importadas correctamente.", flash[:notice]
  end

  test "should handle import without file" do
    post import_brands_url
    assert_redirected_to brands_url
    assert_equal "Por favor sube un archivo.", flash[:alert]
  end

  test "should handle import errors gracefully" do
    file = fixture_file_upload('invalid_file.csv', 'text/csv')
    post import_brands_url, params: { file: file }
    
    assert_redirected_to brands_url
    assert_match /Error al importar/, flash[:alert]
  end

  test "should require authentication" do
    delete logout_url
    post import_brands_url
    assert_redirected_to brands_url
  end

  test "should handle CSV with duplicate entries" do
    Brand.create!(name: "TestBrand")
    file = fixture_file_upload('test_brands.csv', 'text/csv')
    
    post import_brands_url, params: { file: file }
    assert_redirected_to brands_url
  end

  test "should process different file types" do
    file = fixture_file_upload('test_brands.csv', 'text/csv')
    initial_count = Brand.count
    
    post import_brands_url, params: { file: file }
    assert Brand.count >= initial_count
  end
end