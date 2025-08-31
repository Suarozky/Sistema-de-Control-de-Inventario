class SessionsController < ApplicationController
  def new
    # Mostrar formulario de login
  end

  def create
    user = User.find_by(name: params[:name], lastname: params[:lastname])
    
    if user
      session[:user_id] = user.id
      redirect_to home_path, notice: 'Sesión iniciada correctamente' # <-- aquí
    else
      flash.now[:alert] = 'Usuario no encontrado'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: 'Sesión cerrada'
  end

  private

  def session_params
    params.permit(:name, :lastname)
  end
end
