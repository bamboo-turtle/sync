require File.join(Dir.pwd, "test", "test_helper")
require "lib/woo_commerce/store"

class WooCommerceStoreTest < Minitest::Test
  def setup
    @api = Minitest::Mock.new
    @api.expect(:new, @api, [:url, :key, :secret])
    @wc = WooCommerce::Store.new(api: @api, url: :url, key: :key, secret: :secret)
  end

  def test_update_simple_product
    product = build_product("woocommerce_id" => "product-1")

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { "id" => "product-1" } })
    @api.expect(:put, response, ["products/product-1", { product: {
      title: product.name,
      price: product.price,
      short_description: product.short_description,
      description: "<pre>#{product.long_description}</pre>",
      enable_html_description: true,
      categories: [product.category.woocommerce_id],
      images: [{ src: product.images[0], position: 0 }],
    }}])
    updated_product = @wc.update_simple_product(product)
    assert_equal "product-1", updated_product.woocommerce_id
  end

  def test_update_variable_product
    products = [
      build_product("variant" => "variant 1", "images" => ["http://example.com/image1.jpg"], "woocommerce_id" => "product-1:variant-1"),
      build_product("variant" => "variant 2", "images" => ["http://example.com/image2.jpg"], "woocommerce_id" => "product-1:variant-2"),
    ]

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { 
      "id" => "product-1",
      "variations" => [
        { "id" => "variation-1" },
        { "id" => "variation-2" },
      ],
    } })
    @api.expect(:put, response, ["products/product-1", { product: {
      title: products[0].name,
      short_description: products[0].short_description,
      description: "<pre>#{products[0].long_description}</pre>",
      enable_html_description: true,
      categories: [products[0].category.woocommerce_id],
      images: [
        { src: products[0].images[0], position: 0 },
        { src: products[1].images[0], position: 1 },
      ],
      attributes: [
        {
          name: "Option",
          position: 0,
          visible: true,
          variation: true,
          options: products.map(&:variant),
        }
      ],
      variations: [
        {
          regular_price: products[0].price,
          image: { src: products[0].images[0], position: 0 },
          attributes: [
            {
              option: products[0].variant,
              name: "Option",
            }
          ]
        },
        {
          regular_price: products[1].price,
          image: { src: products[1].images[0], position: 0 },
          attributes: [
            {
              option: products[1].variant,
              name: "Option",
            }
          ]
        },
      ]
    }}])
    updated_products = @wc.update_variable_products(products)
    assert_equal 2, updated_products.size
    assert_equal "product-1:variation-1", updated_products[0].woocommerce_id
    assert_equal "product-1:variation-2", updated_products[1].woocommerce_id
  end

  def test_create_product
    product = build_product
    refute product.woocommerce_id

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { "id" => "product-1" } })
    @api.expect(:post, response, ["products", { product: {
      title: product.name,
      type: "simple",
      status: "draft",
      price: product.price,
      short_description: product.short_description,
      description: "<pre>#{product.long_description}</pre>",
      enable_html_description: true,
      categories: [product.category.woocommerce_id],
      images: [{ src: product.images[0], position: 0 }],
    }}])
    products = @wc.store_products([product])
    assert_equal 1, products.size
    assert_equal "product-1", products[0].woocommerce_id
  end

  def test_update_product_via_store_products
    product = build_product("woocommerce_id" => "product-1")
    assert product.woocommerce_id

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { "id" => "product-1" } })
    @api.expect(:put, response, ["products/product-1", { product: {
      title: product.name,
      type: "simple",
      status: "draft",
      price: product.price,
      short_description: product.short_description,
      description: "<pre>#{product.long_description}</pre>",
      enable_html_description: true,
      categories: [product.category.woocommerce_id],
      images: [{ src: product.images[0], position: 0 }],
    }}])
    products = @wc.store_products([product])
    assert_equal 1, products.size
    assert_equal "product-1", products[0].woocommerce_id
  end

  def test_create_variable_product
    products = [
      build_product("variant" => "variant 1", "images" => ["http://example.com/image1.jpg"]),
      build_product("variant" => "variant 2", "images" => ["http://example.com/image2.jpg"]),
    ]

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { 
      "id" => "product-1",
      "variations" => [
        { "id" => "variation-1" },
        { "id" => "variation-2" },
      ],
    } })
    @api.expect(:post, response, ["products", { product: {
      title: products[0].name,
      type: "variable",
      status: "draft",
      short_description: products[0].short_description,
      description: "<pre>#{products[0].long_description}</pre>",
      enable_html_description: true,
      categories: [products[0].category.woocommerce_id],
      images: [
        { src: products[0].images[0], position: 0 },
        { src: products[1].images[0], position: 1 },
      ],
      attributes: [
        {
          name: "Option",
          position: 0,
          visible: true,
          variation: true,
          options: products.map(&:variant),
        }
      ],
      variations: [
        {
          regular_price: products[0].price,
          image: { src: products[0].images[0], position: 0 },
          attributes: [
            {
              option: products[0].variant,
              name: "Option",
            }
          ]
        },
        {
          regular_price: products[1].price,
          image: { src: products[1].images[0], position: 0 },
          attributes: [
            {
              option: products[1].variant,
              name: "Option",
            }
          ]
        },
      ]
    }}])
    products = @wc.store_products(products)

    assert_equal 2, products.size
    assert_equal "product-1:variation-1", products[0].woocommerce_id
    assert_equal "product-1:variation-2", products[1].woocommerce_id
  end

  def test_update_variable_product
    products = [
      build_product("variant" => "variant 1", "images" => ["http://example.com/image1.jpg"], "woocommerce_id" => "product-1:variant-1"),
      build_product("variant" => "variant 2", "images" => ["http://example.com/image2.jpg"], "woocommerce_id" => "product-1:variant-2"),
    ]

    response = Minitest::Mock.new
    response.expect(:parsed_response, { "product" => { 
      "id" => "product-1",
      "variations" => [
        { "id" => "variation-1" },
        { "id" => "variation-2" },
      ],
    } })
    @api.expect(:put, response, ["products/product-1", { product: {
      title: products[0].name,
      type: "variable",
      status: "draft",
      short_description: products[0].short_description,
      description: "<pre>#{products[0].long_description}</pre>",
      enable_html_description: true,
      categories: [products[0].category.woocommerce_id],
      images: [
        { src: products[0].images[0], position: 0 },
        { src: products[1].images[0], position: 1 },
      ],
      attributes: [
        {
          name: "Option",
          position: 0,
          visible: true,
          variation: true,
          options: products.map(&:variant),
        }
      ],
      variations: [
        {
          regular_price: products[0].price,
          image: { src: products[0].images[0], position: 0 },
          attributes: [
            {
              option: products[0].variant,
              name: "Option",
            }
          ]
        },
        {
          regular_price: products[1].price,
          image: { src: products[1].images[0], position: 0 },
          attributes: [
            {
              option: products[1].variant,
              name: "Option",
            }
          ]
        },
      ]
    }}])
    products = @wc.store_products(products)

    assert_equal 2, products.size
    assert_equal "product-1:variation-1", products[0].woocommerce_id
    assert_equal "product-1:variation-2", products[1].woocommerce_id
  end

  def build_product(attributes = {})
    Product.new({
      "name" => "Test product",
      "category" => Category.new("woocommerce_id" => "category-1"),
      "price" => 9.99,
      "short_description" => "Short description",
      "long_description" => "Long description",
      "images" => ["http://example.com/image.jpg"],
      "woocommerce_id" => nil,
    }.merge(attributes))
  end
end
