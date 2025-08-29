# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  def index
    @products = Product.all

  end

  # GET /products/:id
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
     @brands = Brand.all
  @models = Model.all
  end

  # POST /products
  def create
    @product = Product.new(product_params)

   if @product.save
    redirect_to home_path, notice: "Producto creado correctamente."
  else
    render :new, status: :unprocessable_entity
  end
  end

  # GET /products/:id/edit
  def edit
  end

  # PATCH/PUT /products/:id
  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Producto actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /products/:id
  def destroy
    @product.destroy
    redirect_to products_url, notice: "Producto eliminado correctamente."
  end

  private

  # Busca el producto según el ID
  def set_product
    @product = Product.find(params[:id])
  end

  # Permite solo los parámetros válidos
def product_params
  params.require(:product).permit(:model, :brand, :entry_date, :ownerid)
end


end
