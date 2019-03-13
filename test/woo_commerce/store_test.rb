require File.join(Dir.pwd, "test", "test_helper")
require "lib/woo_commerce/store"

class WooCommerceStoreTest < Minitest::Test
  def setup
    @api = Minitest::Mock.new
    @api.expect(:new, @api, [:url, :key, :secret])
    @wc = WooCommerce::Store.new(api: @api, url: :url, key: :key, secret: :secret)
  end

  def test_update_simple_product
    product = Product.new

    wc_product = Minitest::Mock.new
    wc_product.expect(:params, :params)
    wc_product.expect(:id, "product-1")

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { "id" => "product-1" } })

    @api.expect(:put, response, ["products/product-1", :params])

    WooCommerce::Product.stub(:new, wc_product) do
      updated_product = @wc.update_simple_product(product)
      assert_equal "product-1", updated_product.woocommerce_id
      refute updated_product.woocommerce_parent_id
    end
  end

  def test_update_variable_product
    product = VariableProduct.new([Product.new, Product.new])

    wc_product = Minitest::Mock.new
    wc_product.expect(:params, :params)
    wc_product.expect(:id, "product-1")

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { 
      "id" => "product-1",
      "variations" => [
        { "id" => "variation-1" },
        { "id" => "variation-2" },
      ],
    } })

    @api.expect(:put, response, ["products/product-1", :params])

    WooCommerce::VariableProduct.stub(:new, wc_product) do
      updated_product = @wc.update_variable_product(product)
      updated_product.variations[0].tap do |variation|
        assert_equal "product-1", variation.woocommerce_parent_id
        assert_equal "variation-1", variation.woocommerce_id
      end
      updated_product.variations[1].tap do |variation|
        assert_equal "product-1", variation.woocommerce_parent_id
        assert_equal "variation-2", variation.woocommerce_id
      end
    end
  end
end
