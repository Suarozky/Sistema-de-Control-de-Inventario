require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "flash_class returns green classes for notice" do
    result = flash_class('notice')
    assert_equal 'bg-green-100 border border-green-400 text-green-700', result
  end

  test "flash_class returns green classes for notice symbol" do
    result = flash_class(:notice)
    assert_equal 'bg-green-100 border border-green-400 text-green-700', result
  end

  test "flash_class returns red classes for alert" do
    result = flash_class('alert')
    assert_equal 'bg-red-100 border border-red-400 text-red-700', result
  end

  test "flash_class returns red classes for alert symbol" do
    result = flash_class(:alert)
    assert_equal 'bg-red-100 border border-red-400 text-red-700', result
  end

  test "flash_class returns blue classes for unknown type" do
    result = flash_class('unknown')
    assert_equal 'bg-blue-100 border border-blue-400 text-blue-700', result
  end

  test "flash_class returns blue classes for nil" do
    result = flash_class(nil)
    assert_equal 'bg-blue-100 border border-blue-400 text-blue-700', result
  end

  test "flash_class returns blue classes for empty string" do
    result = flash_class('')
    assert_equal 'bg-blue-100 border border-blue-400 text-blue-700', result
  end
end