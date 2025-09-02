class ProductPolicy < ApplicationPolicy

  def update?
    user&.admin? 
  end

  def create?
    user&.admin? 
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user 
        scope.where(ownerid: user.id)
      else
        scope.none 
      end
    end
  end
end