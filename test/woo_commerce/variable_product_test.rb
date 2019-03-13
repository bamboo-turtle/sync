require File.join(Dir.pwd, "test", "test_helper")
require "lib/woo_commerce/variable_product"

class WooCommerceVariableProductTest < Minitest::Test
  def test_id
    product = WooCommerce::VariableProduct.new(
      VariableProduct.new(
        [Product.new("woocommerce_id" => "product-1:varint-1")]
      )
    )
    assert_equal "product-1", product.id
  end

  def test_params
    product = VariableProduct.new([
      Product.new({
        "name" => "Test product",
        "variant" => "variant 1",
        "category" => Category.new("woocommerce_id" => "category-1"),
        "price" => 9.99,
        "short_description" => "Short description",
        "long_description" => "Long description",
        "images" => ["http://example.com/image1.jpg"],
        "woocommerce_id" => "product-1:variant-1",
      }),
      Product.new({
        "name" => "Test product",
        "variant" => "variant 2",
        "category" => Category.new("woocommerce_id" => "category-1"),
        "price" => 19.99,
        "short_description" => "Short description",
        "long_description" => "Long description",
        "images" => ["http://example.com/image2.jpg"],
        "woocommerce_id" => "product-1:variant-2",
      })
    ])
    wc_product = WooCommerce::VariableProduct.new(product)
    params = {
      product: {
        status: "draft",
        title: product.name,
        short_description: product.short_description,
        description: "<pre>#{product.long_description}</pre>",
        enable_html_description: true,
        categories: [product.category.woocommerce_id],
        images: [
          { src: product.images[0], position: 0 },
          { src: product.images[1], position: 1 },
        ],
        attributes: [
          {
            name: "display_price_quantity",
            visible: false,
            variation: false,
            options: product.display_price_quantity,
          },
          {
            name: "Option",
            visible: true,
            variation: true,
            options: product.variants,
          }
        ],
        variations: [
          {
            id: "variant-1",
            regular_price: product.variations[0].price,
            image: { src: product.variations[0].images[0], position: 0 },
            attributes: [
              {
                option: product.variations[0].variant,
                name: "Option",
              }
            ]
          },
          {
            id: "variant-2",
            regular_price: product.variations[1].price,
            image: { src: product.variations[1].images[0], position: 0 },
            attributes: [
              {
                option: product.variations[1].variant,
                name: "Option",
              }
            ]
          },
        ],
      }
    }
    assert_equal params, wc_product.params
  end
end
