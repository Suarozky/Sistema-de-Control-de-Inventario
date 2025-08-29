# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :transactions_history]

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
    previous_owner_id = @product.ownerid

    if @product.update(product_params)
      # Registrar la transacción si cambió el dueño
      if previous_owner_id != @product.ownerid
        Transaction.create(
          ownerid: @product.ownerid,
          productid: @product.id,
          date: Time.current
        )
      end

      owner = User.find_by(id: @product.ownerid)
      render json: {
        model: @product.model,
        brand: @product.brand,
        owner_name: "#{owner&.name} #{owner&.lastname}",
        entry_date: @product.entry_date.strftime("%d/%m/%Y")
      }
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def import
  if params[:file].present?
    ProductImportService.new(params[:file]).call
    redirect_to products_path, notice: "Productos importados correctamente."
  else
    redirect_to products_path, alert: "Por favor sube un archivo."
  end
rescue => e
  redirect_to products_path, alert: "Error al importar: #{e.message}"
end


  # DELETE /products/:id
  def destroy
    @product.destroy
    redirect_to products_url, notice: "Producto eliminado correctamente."
  end

  # GET /products/:id/transactions_history
  def transactions_history
    @transactions = Transaction.where(productid: @product.id).order(date: :desc)
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