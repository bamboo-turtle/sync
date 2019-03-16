require File.join(Dir.pwd, "test", "test_helper")
require "lib/woo_commerce/base_product"

class WooCommerceBaseProductTest < Minitest::Test
  include ProductHelpers

  class ProductAdapter
    include WooCommerce::BaseProduct

    def initialize(product)
      @product = product
    end
  end

  def test_description
    product = build_product("long_description" => nil)
    assert_nil product.product_params[:description]

    product = build_product("long_description" => "Description")
    assert_equal "<pre>Description</pre>", product.product_params[:description]
  end

  def test_status
    product = build_product("enabled" => false)
    assert_equal ProductAdapter::Statuses::DRAFT, product.product_params[:status]

    product = build_product("enabled" => true)
    assert_equal ProductAdapter::Statuses::PUBLISH, product.product_params[:status]
  end

  def test_update_images_only_when_they_change
    product = build_product
    assert product.product_params[:images]

    product = ProductAdapter.new(synced_product(simple_product))
    refute product.product_params[:images]
  end

  def build_product(params = {})
    ProductAdapter.new(simple_product(params))
  end
end
