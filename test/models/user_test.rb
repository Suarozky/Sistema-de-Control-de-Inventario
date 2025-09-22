require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "John", lastname: "Doe", role: :user)
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should save with valid name" do
    assert @user.save
  end

  test "should create user with name and lastname" do
    user = User.create(name: "Test", lastname: "User")
    assert user.persisted?
  end

  test "should not allow duplicate name and lastname combination" do
    @user.save!
    duplicate_user = User.new(name: "John", lastname: "Doe", role: :admin)
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:name], "y apellido ya existen"
  end

  test "should allow different name same lastname" do
    @user.save!
    different_user = User.new(name: "Jane", lastname: "Doe", role: :admin)
    assert different_user.valid?
  end

  test "should allow same name different lastname" do
    @user.save!
    different_user = User.new(name: "John", lastname: "Smith", role: :admin)
    assert different_user.valid?
  end

  test "should have default role of user" do
    user = User.new(name: "Test", lastname: "User")
    assert_equal "user", user.role
  end

  test "should allow admin role" do
    @user.role = :admin
    assert @user.valid?
    assert_equal "admin", @user.role
  end

  test "should have many products" do
    @user.save!
    product = Product.create!(model: "Test Model", brand: "Test Brand", entry_date: Date.current, ownerid: @user.id)
    assert_includes @user.products, product
  end

  test "should be user role by default" do
    user = User.new(name: "Test", lastname: "User")
    assert user.user?
  end

  test "should be able to be admin" do
    @user.role = :admin
    assert @user.admin?
    refute @user.user?
  end

  test "should convert role to string" do
    @user.role = :admin
    assert_equal "admin", @user.role
  end

  test "should handle role enum properly" do
    @user.role = :user
    assert_equal "user", @user.role
    
    @user.role = :admin
    assert_equal "admin", @user.role
  end

  test "name and lastname combination should be case sensitive" do
    @user.save!
    different_case_user = User.new(name: "john", lastname: "doe", role: :user)
    assert different_case_user.valid?
  end
end
