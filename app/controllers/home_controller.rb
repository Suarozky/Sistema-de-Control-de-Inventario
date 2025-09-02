# app/controllers/home_controller.rb
class HomeController < ApplicationController
   before_action :authenticate_user!
def index
    @total_users = User.count
    @total_products = Product.count
    @total_transactions = Transaction.count
    @recent_transactions = Transaction.includes(:owner, :product)
                                    .order(date: :desc)
                                    .limit(5)
  
  end
end
