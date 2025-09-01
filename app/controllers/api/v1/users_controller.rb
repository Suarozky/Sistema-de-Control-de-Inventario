class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    users = User.includes(:products)
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    result = paginate_collection(users, page, per_page)
    
    render_success(
      {
        users: result[:data].map { |user| user_json(user) },
        pagination: result[:pagination]
      }
    )
  end

  def show
    render_success(user: user_json(@user))
  end

  def create
    user = User.new(user_params)
    
    if user.save
      render_success(
        user: user_json(user),
        message: "Usuario creado exitosamente",
        status: :created
      )
    else
      render_error(
        "Error al crear el usuario",
        :unprocessable_entity,
        user.errors.full_messages
      )
    end
  end

  def update
    if @user.update(user_params)
      render_success(
        user: user_json(@user),
        message: "Usuario actualizado exitosamente"
      )
    else
      render_error(
        "Error al actualizar el usuario",
        :unprocessable_entity,
        @user.errors.full_messages
      )
    end
  end

  def destroy
    if @user.destroy
      render_success(message: "Usuario eliminado exitosamente")
    else
      render_error("Error al eliminar el usuario")
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error("Usuario no encontrado", :not_found)
  end

  def user_params
    params.require(:user).permit(:name, :lastname, :role)
  end

  def user_json(user)
    {
      id: user.id,
      name: user.name,
      lastname: user.lastname,
      role: user.role,
      products_count: user.products.count,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end