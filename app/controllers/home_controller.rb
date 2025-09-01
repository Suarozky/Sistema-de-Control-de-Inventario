# app/controllers/home_controller.rb
class HomeController < ApplicationController
def new
    # Conteos principales para el Home
    @total_users = User.count
    @total_products = Product.count
    @total_transactions = Transaction.count
    
    # Transacciones recientes 
    @recent_transactions = Transaction.includes(:owner, :product)
                                    .order(date: :desc)
                                    .limit(10)
  
  end
end
