# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:update, :transactions_history]

  # GET /products
  def index
      @products = policy_scope(Product)  
    @users = User.all
    @models = Model.all
    @brands = Brand.all
    
  end

  # GET /products/new
  def new
    @products = Product.all
    @users = User.all
    @brands = Brand.all
    @models = Model.all
    
    respond_to do |format|
      format.html { render layout: "minimal" }
    end
  end


  # POST /products
  def create
    @product = Product.new(product_params)
    authorize @product
    
    if @product.save
      redirect_to home_path, notice: "Producto creado correctamente."
    else
      # Cargar las variables necesarias para la vista new
      @products = Product.all
      @users = User.all
      @brands = Brand.all
      @models = Model.all
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /products/:id
  def update
    authorize @product
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
        entry_date: @product.entry_date&.strftime("%d/%m/%Y") || ""
      }
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_content
    end
  end

  # POST /products/import
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

  # GET /products/export
  def export
    type = params[:type] || "product"
    allowed_types = ["product", "brand", "model"]
    
    # Validar tipo de exportación
    unless allowed_types.include?(type)
      redirect_to products_path, alert: "Tipo de exportación no válido: #{type}"
      return
    end

    begin
      csv_data = ExportService.new(type).call
      filename = "#{type.pluralize}_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv"
      
      send_data csv_data,
                type: "text/csv; charset=utf-8",
                filename: filename,
                disposition: "attachment"
    rescue => e
      Rails.logger.error "Error en export de #{type}: #{e.message}"
      redirect_to products_path, alert: "Error al exportar #{type}: #{e.message}"
    end
  end

  # GET /products/:id/transactions_history
  def transactions_history
    @transactions = Transaction.where(productid: @product.id).order(date: :desc)
    render layout: "minimal"
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