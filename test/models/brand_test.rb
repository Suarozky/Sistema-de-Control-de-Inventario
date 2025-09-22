require "test_helper"

class BrandTest < ActiveSupport::TestCase
  def setup
    @brand = Brand.new(name: "Test Brand")
  end

  test "should be valid with valid attributes" do
    assert @brand.valid?
  end

  test "should require name" do
    @brand.name = nil
    assert_not @brand.valid?
    assert_includes @brand.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    @brand.save!
    duplicate_brand = Brand.new(name: "Test Brand")
    assert_not duplicate_brand.valid?
    assert_includes duplicate_brand.errors[:name], "has already been taken"
  end

  test "should allow different names" do
    @brand.save!
    different_brand = Brand.new(name: "Different Brand")
    assert different_brand.valid?
  end

  test "should handle empty string name" do
    @brand.name = ""
    assert_not @brand.valid?
    assert_includes @brand.errors[:name], "can't be blank"
  end

  test "should handle whitespace only name" do
    @brand.name = "   "
    assert_not @brand.valid?
  end

  test "should allow long names" do
    @brand.name = "A" * 255
    assert @brand.valid?
  end

  test "should handle case sensitivity" do
    @brand.name = "TestBrand"
    @brand.save!
    
    case_different = Brand.new(name: "testbrand")
    assert case_different.valid?
  end

  test "should have timestamps" do
    @brand.save!
    assert_not_nil @brand.created_at
    assert_not_nil @brand.updated_at
  end
end
