require File.join(Dir.pwd, "test", "test_helper")
require "lib/woo_commerce"

class WooCommerceStoreTest < Minitest::Test
  def test_create_product
    product = Product.new(
      "name" => "Test product",
      "category" => Category.new("woocommerce_id" => "category-1"),
      "price" => 9.99,
      "short_description" => "Short description",
      "long_description" => "Long description",
      "images" => ["http://example.com/image.jpg"],
      "woocommerce_id" => nil,
    )
    refute product.woocommerce_id

    api = Minitest::Mock.new
    api.expect(:new, api, [:api_params])
    wc = WooCommerce::Store.new(api: api, api_params: :api_params)

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { "id" => "product-1" } })
    api.expect(:post, response, ["products", { product: {
      title: "Test product",
      type: "simple",
      status: "draft",
      price: 9.99,
      short_description: "Short description",
      description: "<pre>Long description</pre>",
      enable_html_description: true,
      categories: ["category-1"],
      images: [{ src: "http://example.com/image.jpg", position: 0 }],
    }}])
    product = wc.store_product(product)

    assert_equal "product-1", product.woocommerce_id
  end

  def test_update_product
    product = Product.new(
      "name" => "Test product",
      "category" => Category.new("woocommerce_id" => "category-1"),
      "price" => 9.99,
      "short_description" => "Short description",
      "long_description" => "Long description",
      "images" => ["http://example.com/image.jpg"],
      "woocommerce_id" => "product-1",
    )
    assert product.woocommerce_id

    api = Minitest::Mock.new
    api.expect(:new, api, [:api_params])
    wc = WooCommerce::Store.new(api: api, api_params: :api_params)

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { "id" => "product-1" } })
    api.expect(:put, response, ["products/product-1", { product: {
      title: "Test product",
      type: "simple",
      status: "draft",
      price: 9.99,
      short_description: "Short description",
      description: "<pre>Long description</pre>",
      enable_html_description: true,
      categories: ["category-1"],
      images: [{ src: "http://example.com/image.jpg", position: 0 }],
    }}])
    product = wc.store_product(product)

    assert_equal "product-1", product.woocommerce_id
  end
end
