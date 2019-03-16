require File.join(Dir.pwd, "test", "test_helper")

class WooCommerceVariationTest < Minitest::Test
  include ProductHelpers

  def test_params
    product = Product.new(
      "variant" => "variant 1",
      "price" => 9.99,
      "images" => ["http://example.com/image1.jpg"],
      "woocommerce_id" => "variant-1",
    )
    variation = WooCommerce::Variation.new(product)
    params = {
      id: "variant-1",
      regular_price: product.price,
      image: [{ src: product.images[0], position: 0 }],
      attributes: [
        {
          option: product.variant,
          name: "Option",
        }
      ]
    }
    assert_equal params, variation.params
  end

  def test_update_images_only_when_they_change
    variation = WooCommerce::Variation.new(simple_product)
    assert variation.params[:image]

    variation = WooCommerce::Variation.new(synced_product(simple_product))
    refute variation.params[:image]
  end
end
