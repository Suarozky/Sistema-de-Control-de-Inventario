class UsersController < ApplicationController
  before_action :set_user, only: [:my_products]

  def index
    @users = policy_scope(User)  
    @products = Product.all
    @models = Model.all
    @brands = Brand.all
  end

  def new
    @products = Product.all
    @users = User.all
    @brands = Brand.all
    @models = Model.all
    render layout: "minimal"
  end

  def create
    @user = User.new(user_params)
    @user.role = params[:user][:role] || 'user'
    authorize @user

    if @user.save
      redirect_to home_path, notice: "Usuario creado con éxito"
    else
      @products = Product.all
      @users = User.all
      @brands = Brand.all
      @models = Model.all
      render :new, status: :unprocessable_content, layout: "minimal"
    end
  end

  def count
    @users_count = User.count
    render json: { total_users: @users_count }
  end

  def import
    unless params[:file].present?
      redirect_to users_path, alert: "Por favor sube un archivo."
      return
    end

    begin
      result = UserImportService.new(params[:file]).call
      
      if result[:errors].empty?
        message = "#{result[:success_count]} usuarios importados correctamente."
        message += " #{result[:skipped_count]} usuarios ya existían." if result[:skipped_count] > 0
        redirect_to home_path, notice: message
      else
        error_message = "Se procesaron #{result[:success_count]} usuarios correctamente"
        error_message += ", #{result[:skipped_count]} ya existían" if result[:skipped_count] > 0
        error_message += ". Errores: #{result[:errors].join('; ')}"
        redirect_to home_path, alert: error_message
      end
      
    rescue => e
      Rails.logger.error "Error en import de usuarios: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to home_path, alert: "Error al importar: #{e.message}"
    end
  end

  def export
    csv_data = ExportService.new("user").call
    filename = "users_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv"
    
    send_data csv_data, 
      type: "text/csv; charset=utf-8",
      filename: filename,
      disposition: "attachment"
  end

  def my_products
    # Obtener todos los productos que han tenido transacciones con este usuario
    @products = Product.joins(:transactions)
                       .where(transactions: { ownerid: @user.id })
                       .distinct
                       .includes(:transactions)
    
    # Separar productos actuales y anteriores
    @current_products = []
    @previous_products = []
    
    @products.each do |product|
      # Obtener la transacción más reciente del producto
      latest_transaction = product.transactions.order(date: :desc).first
      
      if latest_transaction.ownerid == @user.id
        @current_products << product
      else
        @previous_products << product
      end
    end
    
    render layout: "minimal"
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    redirect_to users_path, alert: "Usuario no encontrado" unless @user
  end

  def user_params
    params.require(:user).permit(:name, :lastname)
  end
end