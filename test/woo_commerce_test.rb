require File.join(Dir.pwd, "test", "test_helper")
require "lib/woo_commerce"

class WooCommerceTest < Minitest::Test
  DATA_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "data"))

  def setup
    @products = WooCommerce::Product.from_json(File.join(DATA_DIR, "wc_products.json"))
  end

  def test_product
    product = @products.find { |product| product.id == "469" }

    refute product.variable?
    assert_equal "toothpaste", product.name
    assert_equal %w(beauty), product.categories
    assert_match /Natural Toothpaste with pure white clay/, product.short_description
    assert_match /No animal ingredients or testing/, product.long_description
    assert_equal 5, product.price
    assert_equal %w(https://i2.wp.com/bambooturtle.co.uk/wp-content/uploads/2018/05/tooth.jpg), product.images.to_a
    assert_empty product.variants
  end

  def test_product_variant
    product = @products.find { |product| product.id == "465:584" }

    assert_equal "deodorant - natural ", product.name
    assert_equal %w(beauty), product.categories
    assert_equal "", product.short_description
    assert_match /Natural Organic Deodorant Ingredients/ , product.long_description
    assert_equal 7, product.price
    assert_equal %w(
      https://i1.wp.com/bambooturtle.co.uk/wp-content/uploads/2018/05/deo-vegan.jpg
      https://i0.wp.com/bambooturtle.co.uk/wp-content/uploads/2018/05/deo.jpg
      ), product.images.to_a
  end

  def test_images_santize_url
    images = WooCommerce::Images.new(%w(https://example.com/image.jpg?fit=454%2C483))
    assert_equal %w(https://example.com/image.jpg), images.to_a
  end

  def test_images_add
    images = WooCommerce::Images.new(%w(https://example.com/image.jpg?fit=454%2C483)) +
      WooCommerce::Images.new(%w(https://example.com/image.jpg?fit=454%2C483 https://example.com/other_image.jpg))

    assert_equal %w(https://example.com/image.jpg https://example.com/other_image.jpg), images.to_a
  end

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
