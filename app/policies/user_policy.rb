class UserPolicy < ApplicationPolicy
  
  def index?
    user.admin?  # Solo admins pueden ver la lista de usuarios
  end

  def show?
    user.admin? || record == user  # Admins pueden ver cualquier usuario, usuarios normales solo su propio perfil
  end

  def create?
    user.admin?  # Solo admins pueden crear usuarios
  end

  def update?
    user.admin? || record == user  # Admins pueden editar cualquier usuario, usuarios normales solo su propio perfil
  end

  def destroy?
    user.admin? && record != user  # Solo admins pueden eliminar usuarios, pero no a sí mismos
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        User.all  # Los admins pueden ver todos los usuarios
      else
        User.where(id: user.id)  # Los usuarios normales solo pueden ver su propio perfil
      end
    end
  end
end