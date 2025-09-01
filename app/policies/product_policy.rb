# app/policies/product_policy.rb
class ProductPolicy < ApplicationPolicy

  def update?
    user.admin?   # Solo admins pueden actualizar
  end

  def create?
    user.admin?   # Solo admins pueden crear
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(ownerid: user.id)
      end
    end
  end
end
