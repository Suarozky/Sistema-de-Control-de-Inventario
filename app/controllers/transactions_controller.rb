class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]


  def index
    @transactions_count = Transaction.count
    @latest_transactions = Transaction
                             .includes(:product, :owner)
                             .order(date: :desc)
                             .limit(10)
  end

  def show
  end

  def new
    @transaction = Transaction.new
    @products = Product.all
    @users = User.all
  end


  def create
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      redirect_to @transaction, notice: 'Transacción creada exitosamente.'
    else
      @products = Product.all
      @users = User.all
      render :new, status: :unprocessable_entity
    end
  end


  def edit
    @products = Product.all
    @users = User.all
  end


  def update
    if @transaction.update(transaction_params)
      redirect_to @transaction, notice: 'Transacción actualizada exitosamente.'
    else
      @products = Product.all
      @users = User.all
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @transaction.destroy
    redirect_to transactions_path, notice: 'Transacción eliminada.'
  end


  def count
    @transactions_count = Transaction.count
    render json: { total_transactions: @transactions_count }
  end


  def import
    unless params[:file].present?
      redirect_to transactions_path, alert: "Por favor sube un archivo."
      return
    end

    begin
      result = TransactionImportService.new(params[:file]).call
      
      if result[:errors].empty?
        message = "#{result[:success_count]} transacciones importadas correctamente."
        message += " #{result[:skipped_count]} transacciones ya existían." if result[:skipped_count] > 0
        redirect_to transactions_path, notice: message
      else
        error_message = "Se procesaron #{result[:success_count]} transacciones correctamente"
        error_message += ", #{result[:skipped_count]} ya existían" if result[:skipped_count] > 0
        error_message += ". Errores: #{result[:errors].join('; ')}"
        redirect_to transactions_path, alert: error_message
      end
      
    rescue => e
      Rails.logger.error "Error en import de transacciones: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to transactions_path, alert: "Error al importar: #{e.message}"
    end
  end


def export
  csv_data = ExportService.new("transaction").call
  filename = "transactions_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv"
  
  send_data csv_data, 
    type: "text/csv; charset=utf-8",
    filename: filename,
    disposition: "attachment"
end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:productid, :ownerid, :date, :amount, :price)
  end
end