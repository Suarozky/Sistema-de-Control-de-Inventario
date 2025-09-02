require "test_helper"

class BrandsControllerTest < ActionDispatch::IntegrationTest

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

  
end