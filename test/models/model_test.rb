require "test_helper"

class ModelTest < ActiveSupport::TestCase
  def setup
    @model = Model.new(name: "Test Model")
  end

  test "should be valid with valid attributes" do
    assert @model.valid?
  end

  test "should require name" do
    @model.name = nil
    assert_not @model.valid?
    assert_includes @model.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    @model.save!
    duplicate_model = Model.new(name: "Test Model")
    assert_not duplicate_model.valid?
    assert_includes duplicate_model.errors[:name], "has already been taken"
  end

  test "should allow different names" do
    @model.save!
    different_model = Model.new(name: "Different Model")
    assert different_model.valid?
  end

  test "should handle empty string name" do
    @model.name = ""
    assert_not @model.valid?
    assert_includes @model.errors[:name], "can't be blank"
  end

  test "should handle whitespace only name" do
    @model.name = "   "
    assert_not @model.valid?
  end

  test "should allow long names" do
    @model.name = "A" * 255
    assert @model.valid?
  end

  test "should handle case sensitivity" do
    @model.name = "TestModel"
    @model.save!
    
    case_different = Model.new(name: "testmodel")
    assert case_different.valid?
  end

  test "should have timestamps" do
    @model.save!
    assert_not_nil @model.created_at
    assert_not_nil @model.updated_at
  end

  test "should handle special characters" do
    @model.name = "Test-Model_123"
    assert @model.valid?
  end
end
