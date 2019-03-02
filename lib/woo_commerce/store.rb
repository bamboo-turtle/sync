require "woocommerce_api"

module WooCommerce
  class Store
    def initialize(api: WooCommerce::API, url:, key:, secret:, debug: false)
      api_params = [url, key, secret]
      if debug
        params << { httparty_args: { debug_output: $stdout } }
      end
      @api = api.new(*api_params)
    end

    def update_simple_product(product)
      params = {
        product: {
          title: product.name,
          price: product.price,
          short_description: product.short_description,
          description: "<pre>#{product.long_description}</pre>",
          enable_html_description: true,
          categories: [product.category.woocommerce_id],
          images: product.images.map.with_index { |url, i| { src: url, position: i } }
        }
      }
      response = @api.put("products/#{product.woocommerce_id}", params)
      product.update("woocommerce_id" => response.parsed_response.fetch("product").fetch("id"))
    end

    def update_variable_product(products)
      params = {
        product: {
          title: products[0].name,
          short_description: products[0].short_description,
          description: "<pre>#{products[0].long_description}</pre>",
          enable_html_description: true,
          categories: [products[0].category.woocommerce_id],
          images: products.flat_map(&:images).map.with_index { |url, i| { src: url, position: i } },
          attributes: [
            {
              name: "Option",
              position: 0,
              visible: true,
              variation: true,
              options: products.map(&:variant),
            }
          ],
          variations: products.map { |product|
            {
              regular_price: product.price,
              image: { src: product.images[0], position: 0 },
              attributes: [
                {
                  option: product.variant,
                  name: "Option",
                }
              ]
            }
          }
        }
      }

      response = @api.put("products/#{products[0].woocommerce_id.split(":")[0]}", params)
      wc_product = response.parsed_response.fetch("product")
      products.zip(wc_product.fetch("variations")).map { |product, variant|
        product.update("woocommerce_id" => [wc_product.fetch("id"), variant.fetch("id")].join(":"))
      }
    end
  end
end
