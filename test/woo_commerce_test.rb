require "minitest/autorun"
require "woo_commerce"

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
end
