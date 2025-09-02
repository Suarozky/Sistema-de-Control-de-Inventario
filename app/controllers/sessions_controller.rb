class SessionsController < ApplicationController
  def new
    # Mostrar formulario de login
    render layout: "minimal"
  end

  def create
    user = User.find_by(name: params[:name], lastname: params[:lastname])
    
    if user
      session[:user_id] = user.id
      redirect_to home_index_path, notice: 'Sesión iniciada correctamente' 
    else
      flash.now[:alert] = 'Usuario no encontrado'
      redirect_to login_path, alert: 'Usuario no encontrado'
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: 'Sesión cerrada'
  end

  private

  def session_params
    params.permit(:name, :lastname)
  end
end
