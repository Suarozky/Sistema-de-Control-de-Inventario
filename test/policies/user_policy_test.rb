# test/policies/user_policy_test.rb
require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  def test_scope
    admin = users(:admin)
    regular_user = users(:regular)
    
    # Admin puede ver todos los usuarios
    scope = Pundit.policy_scope(admin, User)
    assert_equal User.count, scope.count
    
    # Usuario regular solo puede ver su propio perfil
    scope = Pundit.policy_scope(regular_user, User)
    assert_equal 1, scope.count
    assert_includes scope, regular_user
  end


  def test_create
    admin = users(:admin)
    regular_user = users(:regular)
    
    # Solo admins pueden crear usuarios
    assert UserPolicy.new(admin, User.new).create?
    refute UserPolicy.new(regular_user, User.new).create?
    
    # Manejar usuario nil
    refute UserPolicy.new(nil, User.new).create?
  end

end

