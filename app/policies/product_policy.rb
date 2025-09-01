class ProductPolicy < ApplicationPolicy

  def update?
    user&.admin? # Manejo seguro de nil
  end

  def create?
    user&.admin? # Cambiado: agregado & para manejo seguro de nil
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? # Cambiado: agregado & para manejo seguro de nil
        scope.all
      elsif user # Verificar que user no sea nil antes de acceder a .id
        scope.where(ownerid: user.id)
      else
        scope.none # Si no hay usuario, no mostrar nada
      end
    end
  end
end