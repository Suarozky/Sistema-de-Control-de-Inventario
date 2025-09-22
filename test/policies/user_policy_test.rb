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

  def test_scope_with_nil_user
    scope = Pundit.policy_scope(nil, User)
    assert_equal 0, scope.count
  end

  def test_policy_initialization
    admin = users(:admin)
    user = users(:regular)
    policy = UserPolicy.new(admin, user)
    
    assert_equal admin, policy.user
    assert_equal user, policy.record
  end

  def test_show_permissions
    admin = users(:admin)
    regular_user = users(:regular)
    
    # Test default behavior from ApplicationPolicy
    refute UserPolicy.new(admin, regular_user).show?
    refute UserPolicy.new(regular_user, admin).show?
    refute UserPolicy.new(nil, regular_user).show?
  end

  def test_update_permissions
    admin = users(:admin)
    regular_user = users(:regular)
    
    # UserPolicy inherits from ApplicationPolicy which defaults to false for update
    refute UserPolicy.new(admin, regular_user).update?
    refute UserPolicy.new(regular_user, admin).update?
    refute UserPolicy.new(nil, regular_user).update?
  end

end

