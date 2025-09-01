require "test_helper"

class ModelsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get models_url
    assert_response :success
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

  test "should load all models in index" do
    model1 = Model.create!(name: "Model 1")
    model2 = Model.create!(name: "Model 2")
    
    get models_url, headers: { "Accept" => "text/html" }
    assert_response :success
  end
end