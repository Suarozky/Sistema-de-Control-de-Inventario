class Api::V1::TransactionsController < Api::V1::BaseController
  before_action :set_transaction, only: [:show, :update, :destroy]

  def index
    transactions = Transaction.includes(:product, :owner)
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    result = paginate_collection(transactions, page, per_page)
    
    render_success(
      {
        transactions: result[:data].map { |transaction| transaction_json(transaction) },
        pagination: result[:pagination]
      }
    )
  end

  def show
    render_success(transaction: transaction_json(@transaction))
  end

  def create
    transaction = Transaction.new(transaction_params)
    
    if transaction.save
      render_success(
        transaction: transaction_json(transaction),
        message: "Transferencia creada exitosamente",
        status: :created
      )
    else
      render_error(
        "Error al crear la transferencia",
        :unprocessable_entity,
        transaction.errors.full_messages
      )
    end
  end

  def update
    if @transaction.update(transaction_params)
      render_success(
        transaction: transaction_json(@transaction),
        message: "Transferencia actualizada exitosamente"
      )
    else
      render_error(
        "Error al actualizar la transferencia",
        :unprocessable_entity,
        @transaction.errors.full_messages
      )
    end
  end

  def destroy
    if @transaction.destroy
      render_success(message: "Transferencia eliminada exitosamente")
    else
      render_error("Error al eliminar la transferencia")
    end
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Transferencia no encontrada", :not_found)
  end

  def transaction_params
    params.require(:transaction).permit(:productid, :ownerid, :date)
  end

  def transaction_json(transaction)
    {
      id: transaction.id,
      date: transaction.date,
      product: transaction.product ? {
        id: transaction.product.id,
        model: transaction.product.model,
        brand: transaction.product.brand,
      } : nil,
      owner: transaction.owner ? {
        id: transaction.owner.id,
        name: transaction.owner.name,
        lastname: transaction.owner.lastname
      } : nil,
      created_at: transaction.created_at,
      updated_at: transaction.updated_at
    }
  end
end