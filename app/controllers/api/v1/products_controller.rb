class Api::V1::ProductsController < Api::V1::BaseController
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    products = Product.includes(:owner)
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    result = paginate_collection(products, page, per_page)
    
    render_success(
      {
        products: result[:data].map { |product| product_json(product) },
        pagination: result[:pagination]
      }
    )
  end

  def show
    render_success(product: product_json(@product))
  end

  def create
    product = Product.new(product_params)
    
    if product.save
      render_success(
        product: product_json(product),
        message: "Producto creado exitosamente",
        status: :created
      )
    else
      render_error(
        "Error al crear el producto",
        :unprocessable_entity,
        product.errors.full_messages
      )
    end
  end

  def update
    if @product.update(product_params)
      render_success(
        product: product_json(@product),
        message: "Producto actualizado exitosamente"
      )
    else
      render_error(
        "Error al actualizar el producto",
        :unprocessable_entity,
        @product.errors.full_messages
      )
    end
  end

  def destroy
    if @product.destroy
      render_success(message: "Producto eliminado exitosamente")
    else
      render_error("Error al eliminar el producto")
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Producto no encontrado", :not_found)
  end

  def product_params
    params.require(:product).permit(:model, :brand, :entry_date, :ownerid)
  end

  def product_json(product)
    {
      id: product.id,
      model: product.model,
      brand: product.brand,
      entry_date: product.entry_date,
      owner: product.owner ? {
        id: product.owner.id,
        name: product.owner.name,
        lastname: product.owner.lastname
      } : nil,
      created_at: product.created_at,
      updated_at: product.updated_at
    }
  end
end