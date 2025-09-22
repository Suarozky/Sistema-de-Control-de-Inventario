# test/policies/product_policy_test.rb
require 'test_helper'

class ProductPolicyTest < ActiveSupport::TestCase
  def test_scope
    admin = users(:admin)
    regular_user = users(:regular)
    product = products(:one)
    
    # Test que admin puede ver todos los productos
    scope = Pundit.policy_scope(admin, Product)
    assert_includes scope, product
    
    # Test que usuario regular solo ve sus propios productos
    scope = Pundit.policy_scope(regular_user, Product)
    # Asume que el producto pertenece al usuario regular
    # Ajusta según tu lógica de negocio
  end

  def test_create
    admin = users(:admin)
    regular_user = users(:regular)
    
    # Solo admins pueden crear productos
    assert ProductPolicy.new(admin, Product.new).create?
    refute ProductPolicy.new(regular_user, Product.new).create?
    
    # Manejar usuario nil
    refute ProductPolicy.new(nil, Product.new).create?
  end

  def test_update
    admin = users(:admin)
    regular_user = users(:regular)
    product = products(:one)
    
    # Solo admins pueden actualizar productos
    assert ProductPolicy.new(admin, product).update?
    refute ProductPolicy.new(regular_user, product).update?
    
    # Manejar usuario nil
    refute ProductPolicy.new(nil, product).update?
  end

  def test_show
    admin = users(:admin)
    regular_user = users(:regular)
    product = products(:one)
    
    # Por defecto ApplicationPolicy retorna false para show
    refute ProductPolicy.new(admin, product).show?
    refute ProductPolicy.new(regular_user, product).show?
    refute ProductPolicy.new(nil, product).show?
  end

  def test_index
    admin = users(:admin)
    regular_user = users(:regular)
    
    # Por defecto ApplicationPolicy retorna false para index
    refute ProductPolicy.new(admin, Product).index?
    refute ProductPolicy.new(regular_user, Product).index?
    refute ProductPolicy.new(nil, Product).index?
  end

  def test_destroy
    admin = users(:admin)
    regular_user = users(:regular)
    product = products(:one)
    
    # Por defecto ApplicationPolicy retorna false para destroy
    refute ProductPolicy.new(admin, product).destroy?
    refute ProductPolicy.new(regular_user, product).destroy?
    refute ProductPolicy.new(nil, product).destroy?
  end
end

