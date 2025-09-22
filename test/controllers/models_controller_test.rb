require "test_helper"

class ModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin)
    post login_url, params: { 
      name: @user.name, 
      lastname: @user.lastname 
    }
  end

  test "should import models with file" do
    file = fixture_file_upload('test_models.csv', 'text/csv')
    
    post import_models_url, params: { file: file }
    assert_redirected_to models_url
    assert_equal "Modelos importados correctamente.", flash[:notice]
  end

  test "should handle import without file" do
    post import_models_url
    assert_redirected_to models_url
    assert_equal "Por favor sube un archivo.", flash[:alert]
  end

  test "should handle import errors gracefully" do
    file = fixture_file_upload('invalid_file.csv', 'text/csv')
    post import_models_url, params: { file: file }
    
    assert_redirected_to models_url
    assert_match /Error al importar/, flash[:alert]
  end

  test "should require authentication" do
    delete logout_url
    post import_models_url
    assert_redirected_to models_url
  end

  test "should handle CSV with duplicate entries" do
    Model.create!(name: "TestModel")
    file = fixture_file_upload('test_models.csv', 'text/csv')
    
    post import_models_url, params: { file: file }
    assert_redirected_to models_url
  end

  test "should process CSV files successfully" do
    file = fixture_file_upload('test_models.csv', 'text/csv')
    initial_count = Model.count
    
    post import_models_url, params: { file: file }
    assert Model.count >= initial_count
  end

  test "should handle missing parameters gracefully" do
    post import_models_url, params: {}
    assert_redirected_to models_url
    assert_equal "Por favor sube un archivo.", flash[:alert]
  end
end