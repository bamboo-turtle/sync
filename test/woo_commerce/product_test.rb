require File.join(Dir.pwd, "test", "test_helper")
require "lib/woo_commerce/product"

class WooCommerceProductTest < Minitest::Test
  def test_id
    product = WooCommerce::Product.new(Product.new("woocommerce_id" => "product-1"))
    assert_equal "product-1", product.id
  end

  def test_params
    product = Product.new(
      "name" => "Test product",
      "category" => Category.new("woocommerce_id" => "category-1"),
      "price" => 9.99,
      "short_description" => "Short description",
      "long_description" => "Long description",
      "images" => ["http://example.com/image.jpg"],
    )
    wc_product = WooCommerce::Product.new(product)
    params = {
      product: {
        title: product.name,
        regular_price: product.price,
        short_description: product.short_description,
        description: "<pre>#{product.long_description}</pre>",
        enable_html_description: true,
        categories: [product.category.woocommerce_id],
        images: [{ src: product.images[0], position: 0 }],
      }
    }
    assert_equal params, wc_product.params
  end
end
