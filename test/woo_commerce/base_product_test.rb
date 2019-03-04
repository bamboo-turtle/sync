require File.join(Dir.pwd, "test", "test_helper")
require "lib/woo_commerce/base_product"

class WooCommerceBaseProductTest < Minitest::Test
  class ProductAdapter
    include WooCommerce::BaseProduct

    def initialize(product)
      @product = product
    end
  end

  def test_description
    product = ProductAdapter.new(Product.new)
    assert_nil product.product_params[:description]

    product = ProductAdapter.new(Product.new("long_description" => "Description"))
    assert_equal "<pre>Description</pre>", product.product_params[:description]
  end
end
