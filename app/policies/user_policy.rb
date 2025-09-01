class UserPolicy < ApplicationPolicy
  

  def create?
    user&.admin? # Cambiado: agregado & para manejo seguro de nil
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? # Cambiado: agregado & para manejo seguro de nil
        User.all # Los admins pueden ver todos los usuarios
      elsif user # Verificar que user no sea nil
        User.where(id: user.id) # Los usuarios normales solo pueden ver su propio perfil
      else
        User.none # Si no hay usuario, no mostrar nada
      end
    end
  end
end