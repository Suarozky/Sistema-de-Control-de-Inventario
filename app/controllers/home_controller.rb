# app/controllers/home_controller.rb
class HomeController < ApplicationController
def new
    # Conteos principales para el dashboard
    @total_users = User.count
    @total_products = Product.count
    @total_transactions = Transaction.count
    
    # Transacciones recientes con includes para evitar N+1 queries
    @recent_transactions = Transaction.includes(:owner, :product)
                                    .order(date: :desc)
                                    .limit(10)
    
    # Datos adicionales que podrías necesitar
    @transactions_today = Transaction.where(date: Date.current.beginning_of_day..Date.current.end_of_day).count
    @transactions_this_month = Transaction.where(date: Date.current.beginning_of_month..Date.current.end_of_month).count
  end
end
