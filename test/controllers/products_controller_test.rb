require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
    setup do
    @product = products(:one)
    @user = users(:admin)
    # Simular login estableciendo la sesión directamente
    post login_url, params: { 
      name: @user.name, 
      lastname: @user.lastname 
    }
  end

  # ... resto de los tests igual ...

  test "should create product" do
    # Si necesitas pasar el current_user en el request:
    assert_difference("Product.count") do
      post products_url, params: { 
        product: { 
          model: "Test Model", 
          brand: "Test Brand",
          entry_date: Date.current,
          ownerid: @user.id
        }
      }, headers: { 'HTTP_AUTHORIZATION' => @user.id } # O como manejes auth
    end

    assert_redirected_to home_url
    assert_equal "Producto creado correctamente.", flash[:notice]
  end

  test "should not create product with invalid data" do
    assert_no_difference("Product.count") do
      post products_url, params: { 
        product: { 
          model: nil, 
          brand: nil,
          entry_date: nil,
          ownerid: nil
        }
      }, headers: { 'HTTP_AUTHORIZATION' => @user.id }
    end

    assert_response :unprocessable_content
  end

  test "should update product" do
    patch product_url(@product), params: { 
      product: { 
        model: "Updated Model",
        brand: "Updated Brand",
        ownerid: @user.id
      }
    }, headers: { 'HTTP_AUTHORIZATION' => @user.id }
    
    assert_response :success
    @product.reload
    assert_equal "Updated Model", @product.model
  end

  test "should create transaction when owner changes" do
    new_user = User.create!(name: "Test", lastname: "User")
    
    assert_difference("Transaction.count") do
      patch product_url(@product), params: { 
        product: { 
          model: @product.model,
          brand: @product.brand,
          ownerid: new_user.id
        } 
      }
    end
    
    assert_response :success
  end

  test "should get product count" do
    get count_products_url
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["total_users"]
  end


  test "should get transactions history" do
    get transactions_history_product_url(@product)
    assert_response :success
    assert_not_nil assigns(:transactions)
  end

  test "should import products with file" do
    file = fixture_file_upload('test_products.csv', 'text/csv')
    
    post import_products_url, params: { file: file }
    assert_redirected_to products_url
    assert_match /importados correctamente/, flash[:notice]
  end

  test "should handle import without file" do
    post import_products_url
    assert_redirected_to products_url
    assert_equal "Por favor sube un archivo.", flash[:alert]
  end

  test "should export products" do
    get export_products_url, params: { type: "product" }
    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.content_type
  end

  test "should reject invalid export type" do
    get export_products_url, params: { type: "invalid" }
    assert_redirected_to products_url
    assert_match /Tipo de exportación no válido/, flash[:alert]
  end
end