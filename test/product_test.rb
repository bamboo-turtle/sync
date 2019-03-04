require File.join(Dir.pwd, "test", "test_helper")
require "lib/product"

class ProductTest < Minitest::Test
  def test_display_price_quantity
    product = Product.new
    assert_equal 1, product.display_price_quantity

    product = Product.new("display_price_quantity" => 100)
    assert_equal 100, product.display_price_quantity
  end

  def test_display_price
    product = Product.new("price" => 0.00123, "display_price_quantity" => 100)
    assert_equal 0.123, product.display_price
  end
end
