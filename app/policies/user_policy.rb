class UserPolicy < ApplicationPolicy
  

  def create?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? 
        User.all 
      elsif user 
        User.where(id: user.id) 
      else
        User.none 
      end
    end
  end
end