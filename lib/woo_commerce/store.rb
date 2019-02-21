require "woocommerce_api"

module WooCommerce
  class Store
    def initialize(api: WooCommerce::API, api_params: [])
      @api = api.new(*api_params)
    end

    def store_product(product)
      params = {
        product: {
          title: product.name,
          type: "simple",
          status: "draft",
          price: product.price,
          short_description: product.short_description,
          description: "<pre>#{product.long_description}</pre>",
          enable_html_description: true,
          categories: [product.category.woocommerce_id],
          images: product.images.map.with_index { |url, i| { src: url, position: i } }
        }
      }

      response = if product.woocommerce_id
        @api.put("products/#{product.woocommerce_id}", params)
      else
        @api.post("products", params)
      end

      product.update("woocommerce_id" => response.parsed_response.fetch("product").fetch("id"))
    end
  end
end
